# CLAUDE.md

> This file stacks on top of the workspace root at `C:\Code\GitHub\`:
> - Root [`CLAUDE.md`](../../CLAUDE.md) -- voice, rules, routing map, references, skills, slash commands, conventions.
> - Root [`MEMORY.md`](../../MEMORY.md) -- live facts across repos.
> - Root [`STATUS.md`](../../STATUS.md) -- live PR/CI/security dashboard.
> - [`.claude/resources/`](../../.claude/resources/README.md) -- deep reference for collaboration, workflow, git, OSS, debugging, voice.
>
> Read those first. The guidance below only adds **repo-specific context** -- it does not override anything in the root.

## Project

Terraform IaC for a multi-environment (dev/test/prod) Blue/Green deployment pipeline on AWS: ECS on EC2, ALB with blue/green target groups, CodePipeline V2 + CodeBuild + a 30% canary rollout on CodeDeploy or ECS native blue/green (`deployment_engine`), alarm rollback, ECR, KMS, scoped IAM. Ships a small Express + React reference app (`Test_App/`) as the deployable workload.

Portfolio/demo repo by @Sagargupta16. No hosted URL; deploys into an AWS account via `terraform apply`.

## Stack

- **Language**: HCL (Terraform >= 1.10, AWS provider ~> 6.0, pinned by the committed `.terraform.lock.hcl`) + Node.js (Express) + React on Vite 8 for the reference app
- **Framework**: hand-rolled Terraform modules (no registry modules); Express 4 backend with X-Ray SDK
- **Database**: none
- **Package manager**: Yarn (Test_App only)
- **Deploy target**: AWS us-east-1 (ECS/EC2 via CodePipeline blue/green); CI on GitHub Actions

## Run

```
cd terraform
terraform -chdir=bootstrap apply           # once per account: S3 state bucket
terraform -chdir=bootstrap output -raw backend_hcl > backend.hcl
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
terraform output        # prints dev/test/prod ALB DNS names
```

Reference app locally:

```
cd Test_App
yarn all-install        # backend + frontend install, builds React client
yarn start              # Express on port 3000
```

## Test

```
cd Test_App
yarn test               # Jest + Supertest against the real index.js
yarn test --coverage    # fails below 80% lines (jest.coverageThreshold in package.json); CodeBuild runs this
```

Terraform (no AWS account needed, providers are mocked):

```
cd terraform
terraform init -backend=false
terraform test                 # tests/*.tftest.hcl, mocks in tests/mocks/
terraform -chdir=bootstrap test
tflint --init; tflint          # .tflint.hcl, AWS ruleset
bash ../scripts/tests/render-deploy-artifacts.test.sh
```

CI (`.github/workflows/ci.yml`): the shared workflow (fmt, validate, Checkov with soft_fail) plus `terraform test`, tflint, the Test_App coverage gate and client build, and the renderer tests. Module-level runs use `command = plan` with `override_during = plan`: a mocked apply regenerates the ECS service's computed `load_balancer` block and drops `advanced_configuration`.

## Entry points

- `terraform/main.tf` -- root module wiring the submodules (s3, vpc, kms, ecr, iam, task_definition, codebuild, codedeploy per env, codepipeline_dev, codepipeline_main); alb/asg/ecs nest inside codedeploy -> ecs
- `Test_App/index.js` -- Express backend with X-Ray middleware
- `buildspec.yml` (repo root) -- the ACTIVE CodeBuild spec; `Test_App/buildspec.yml` is a stale alternate (still emits the old fixed-ARN appspec, does not work with the CodeDeployToECS action)
- `scripts/render-deploy-artifacts.sh` -- called by the buildspec; writes taskdef.json, imageDetail.json, appspec.yml, imagedefinitions.json pinned to the image digest

## Key files

- `terraform/variables.tf` + `terraform/terraform.tfvars` -- all inputs (region, sizing, branch names, CodeConnections ARN, `deployment_engine`)
- `terraform/versions.tf` -- provider pins + `default_tags` (the only place tags are set)
- `.github/workflows/ci.yml` -- shared `Sagargupta16/shared-workflows` terraform-ci (fmt/validate + Checkov SARIF) plus repo jobs: terraform test + tflint, Test_App, renderer tests

## Gotchas

- **State is S3** since 1.4.0: `backend.tf` is a partial `backend "s3" {}`, values come from the gitignored `backend.hcl` (`bootstrap/` prints it). A plain `terraform init` now asks for the bucket; an existing local `terraform.tfstate` moves over with `-migrate-state`. CI uses `-backend=false`. Never commit state files.
- **Two engines** behind `deployment_engine`: `codedeploy` (default) and `ecs` (ECS native blue/green). The `codedeploy` module name is historical: it always builds the env's ECS stack and adds CodeDeploy only for that engine (resources have `count` plus `moved` blocks). Any new deploy feature needs both paths and a run in `tests/` for each.
- **Windows checkouts are CRLF** (`core.autocrlf`); a heredoc in a `.tf` file carries the `\r`. User data strips it with `replace(..., "\r", "")`; do the same for any new heredoc that reaches a shell. `.gitattributes` keeps `*.sh` LF.
- `terraform/terraform.tfvars` is committed and contains a real CodeConnections (codestar-connections) ARN with the AWS account ID -- deviates from the workspace infra rule (no real `.tfvars` values). Flag before adding more real values; don't add secrets.
- Pipeline trigger branches in tfvars are `master` and `feature/modifications` -- those are the deployed app-source branches CodePipeline watches, not this repo's CI branch (`main`). Don't "fix" them to `main` without checking the live connection setup.
- Tagging is provider-level `default_tags` only. Modules do not accept a `tags` variable -- never add per-resource `tags =` (exception: `aws_autoscaling_group` `tag {}` blocks, required by AWS).
- `terraform/codecommit/` is deprecated (GitHub source replaced CodeCommit). Don't extend it.
- Listeners ignore `default_action` and the ECS-native listener rules ignore `action`: CodeDeploy / ECS move traffic there, and Terraform must not move it back.
- The buildspec starts `dockerd` manually even though the CodeBuild module already sets `privileged_mode = true`; if builds hang there, that is why.
- Test_App uses Yarn, not pnpm -- CodeBuild and the Dockerfile assume Yarn.

## Environment          (IaC)

- Environments: dev / test / prod -- each gets its own ECS cluster, ALB (blue/green target groups), and ASG in one account, us-east-1
- State backend: S3 with native lock file (`use_lockfile`), bucket from `terraform/bootstrap/` (versioned, SSE-KMS, `prevent_destroy`)
- Required secrets: `github_connection_arn` (CodeConnections ARN, currently in tfvars)
- Destroy safeguards: ALB deletion protection on; prod deploys gated by a manual approval stage in the main pipeline; `prevent_destroy` only on the state bucket
- Rollback: per-env alarms `<env>-Target-5XX` and `<env>-Unhealthy-Hosts` roll back either engine; all alarms notify `<env>-alarms` (SNS, CMK-encrypted, optional `alarm_email`)
