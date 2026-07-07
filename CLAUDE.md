# CLAUDE.md

> This file stacks on top of the workspace root at `C:\Code\GitHub\`:
> - Root [`CLAUDE.md`](../../CLAUDE.md) -- voice, rules, routing map, references, skills, slash commands, conventions.
> - Root [`MEMORY.md`](../../MEMORY.md) -- live facts across repos.
> - Root [`STATUS.md`](../../STATUS.md) -- live PR/CI/security dashboard.
> - [`.claude/resources/`](../../.claude/resources/README.md) -- deep reference for collaboration, workflow, git, OSS, debugging, voice.
>
> Read those first. The guidance below only adds **repo-specific context** -- it does not override anything in the root.

## Project

Terraform IaC for a multi-environment (dev/test/prod) Blue/Green deployment pipeline on AWS: ECS on EC2, ALB with blue/green target groups, CodePipeline V2 + CodeBuild + CodeDeploy canary rollout, ECR, KMS, scoped IAM. Ships a small Express + React reference app (`Test_App/`) as the deployable workload.

Portfolio/demo repo by @Sagargupta16. No hosted URL; deploys into an AWS account via `terraform apply`.

## Stack

- **Language**: HCL (Terraform >= 1.1.0, AWS provider ~> 6.0) + Node.js (Express) + React (CRA) for the reference app
- **Framework**: hand-rolled Terraform modules (no registry modules); Express 4 backend with X-Ray SDK
- **Database**: none
- **Package manager**: Yarn (Test_App only)
- **Deploy target**: AWS us-east-1 (ECS/EC2 via CodePipeline blue/green); CI on GitHub Actions

## Run

```
cd terraform
terraform init
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
yarn test               # Jest + Supertest; CodeBuild gates on >= 80% coverage
```

No Terraform test suite. CI runs `terraform fmt -check` + `terraform validate` + Checkov via the shared workflow.

## Entry points

- `terraform/main.tf` -- root module wiring the submodules (s3, vpc, kms, ecr, iam, task_definition, codebuild, codedeploy per env, codepipeline_dev, codepipeline_main); alb/asg/ecs nest inside codedeploy -> ecs
- `Test_App/index.js` -- Express backend with X-Ray middleware
- `buildspec.yml` (repo root) -- the ACTIVE CodeBuild spec; `Test_App/buildspec.yml` is a stale alternate

## Key files

- `terraform/variables.tf` + `terraform/terraform.tfvars` -- all inputs (region, sizing, branch names, CodeStar connection ARN)
- `terraform/versions.tf` -- provider pins + `default_tags` (the only place tags are set)
- `.github/workflows/ci.yml` -- thin caller of `Sagargupta16/shared-workflows` terraform-ci (fmt/validate + Checkov SARIF)

## Gotchas

- **State is local** (`terraform/terraform.tfstate`), no S3 backend or lock table. Known debt, README flags it. Never commit state files.
- `terraform/terraform.tfvars` is committed and contains a real CodeStar Connection ARN with the AWS account ID -- deviates from the workspace infra rule (no real `.tfvars` values). Flag before adding more real values; don't add secrets.
- Pipeline trigger branches in tfvars are `master` and `feature/modifications` -- those are the deployed app-source branches CodePipeline watches, not this repo's CI branch (`main`). Don't "fix" them to `main` without checking the live CodeStar connection setup.
- Tagging is provider-level `default_tags` only. Modules do not accept a `tags` variable -- never add per-resource `tags =` (exception: `aws_autoscaling_group` `tag {}` blocks, required by AWS).
- `terraform/codecommit/` is deprecated (GitHub source replaced CodeCommit). Don't extend it.
- The buildspec starts `dockerd` manually even though the CodeBuild module already sets `privileged_mode = true`; if builds hang there, that is why.
- Test_App uses Yarn, not pnpm -- CodeBuild and the Dockerfile assume Yarn.

## Environment          (IaC)

- Environments: dev / test / prod -- each gets its own ECS cluster, ALB (blue/green target groups), and ASG in one account, us-east-1
- State backend: local (`terraform/terraform.tfstate`) -- migrate to S3 + DynamoDB lock before any real use
- Required secrets: `github_connection_arn` (CodeStar Connection ARN, currently in tfvars)
- Destroy safeguards: ALB deletion protection on; prod deploys gated by a manual approval stage in the main pipeline; no `prevent_destroy` lifecycle rules
