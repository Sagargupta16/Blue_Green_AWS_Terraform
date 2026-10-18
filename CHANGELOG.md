# Changelog

## [1.4.0] - 2026-10-18

### Added
- ECS native blue/green as a second engine: `deployment_engine = "ecs"` switches each service to the `ECS` controller with the `CANARY` (30% for 1 min, default) or `BLUE_GREEN` strategy, a bake time, the deployment circuit breaker and alarm rollback. It adds weighted listener rules on `:80`/`:8080`, the ECS infrastructure role (`AmazonECSInfrastructureRolePolicyForLoadBalancers`) and the CodePipeline ECS deploy action, and drops every CodeDeploy resource. `deployment_engine = "codedeploy"` stays the default; the CodeDeploy resources gained `count` with `moved` blocks, so existing state keeps its addresses.
- Rollback alarms per environment: `<env>-Target-5XX` (>= 5 target 5xx a minute) and `<env>-Unhealthy-Hosts` (worst of blue and green, 2 minutes). CodeDeploy watches them through `alarm_configuration` and `DEPLOYMENT_STOP_ON_ALARM`; the `ecs` engine through the service `alarms` block. Every alarm, including the CPU reservation alarm that had `alarm_actions = []`, notifies a CMK-encrypted SNS topic; `alarm_email` subscribes an address.
- Remote state: partial `backend "s3" {}` with `use_lockfile` (no DynamoDB) and a `terraform/bootstrap/` root module that creates a versioned, SSE-KMS, public-access-blocked, TLS-only state bucket with `prevent_destroy`, plus an SSE-S3 access-log bucket that records every state read and write (log delivery scoped to the state bucket and account, logs kept 365 days by default via `access_log_days`). `.terraform.lock.hcl` is now committed for both root modules, with hashes for linux, darwin and windows.
- `terraform test` suite (`terraform/tests/`, 21 runs) on mocked providers: both engines from the root, variable validation, the ECS service wiring, CodeDeploy alarm rollback, pipeline deploy actions, IAM grants per engine, listener rules, and the user-data shebang; plus 3 runs in `terraform/bootstrap/tests/` for the state bucket.
- CI jobs: `terraform test`, tflint 0.64 with the AWS ruleset (root and bootstrap), the Test_App coverage gate and client build, and the deploy-artifact renderer tests.
- New inputs: `deployment_engine`, `ecs_deployment_strategy`, `canary_percent`, `canary_interval_minutes`, `bake_time_minutes`, `alarm_email`. The CodeDeploy canary reads the same values instead of hardcoded 30 / 1.

### Changed
- Deploys are pinned to the image digest. The buildspec tags images `<env>-<git sha>`, and [`scripts/render-deploy-artifacts.sh`](scripts/render-deploy-artifacts.sh) writes `taskdef.json` (from the Terraform-registered task definition, app image set to `<IMAGE1_NAME>`), `imageDetail.json`, `appspec.yml` (`<TASK_DEFINITION>`) and `imagedefinitions.json` with `repo@sha256:...`. The deploy action is now `CodeDeployToECS` (or `ECS`), which registers a task-definition revision per build, so test and prod run the image the build tested even if a newer build lands while prod waits for approval. The script refuses a mutable tag or an unknown container; 17 checks in `scripts/tests/`.
- Tests and the coverage gate run before `docker build`, and `on-failure: ABORT` on the pre_build and build phases keeps CodeBuild out of post_build, so an image that failed its tests is never pushed (before, post_build ran after a failed build phase and pushed `:<env>-latest`).
- Container-instances use the Amazon Linux 2023 ECS-optimized AMI (AL2 reached end of support on 2026-06-30) and `t3.large` instead of `t2.large`.
- CodeConnections naming: the pipeline role allows `codeconnections:UseConnection` and `codestar-connections:UseConnection`, scoped to the one connection ARN instead of `*`.
- Pipeline role: `ecs:RegisterTaskDefinition`, `ecs:DescribeTaskDefinition`, `ecs:TagResource` (on `RegisterTaskDefinition` only), PassRole for both task roles, and `ecs:UpdateService` on this project's clusters only with the `ecs` engine. CodeBuild role: `ecs:DescribeTaskDefinition`.
- The KMS key has an explicit policy: the default account statement plus CloudWatch, so alarms can publish to the encrypted topics.
- Terraform `required_version` is now `>= 1.10.0` (S3 `use_lockfile`).
- Breaking for local runs: with the partial S3 backend, a plain `terraform init` in `terraform/` now prompts for a bucket. Run `terraform init -backend-config=backend.hcl` (add `-migrate-state` once if you have a local `terraform.tfstate`), or `terraform init -backend=false` for validate and test only.
- Checkov 3.3.29 on `terraform/`: 71 failed / 233 passed before, 70 failed / 282 passed / 6 skipped after. The KMS key policy clears CKV2_AWS_64. The bootstrap module has 0 failures: the state bucket passes 16 checks and skips 2 with an inline reason (replication, event notifications), the access-log bucket passes 15 and skips 4 (logging to itself, replication, KMS, which S3 log delivery does not support, event notifications).

### Fixed
- Listeners ignore `default_action`. CodeDeploy points them at the green target group on every deployment, and the next `terraform apply` used to point traffic back at a target group that could have no tasks.
- User data strips `\r`. On a Windows checkout (`core.autocrlf=true`) the heredoc carried CRLF, the shebang read `/bin/bash\r`, and the script that writes `ECS_CLUSTER` could not run. Caught by the new `asg` test; `.gitattributes` keeps `*.sh` LF for the same reason.

### Docs
- README: both engines in the architecture and sequence diagrams, how to switch an existing stack to `ecs`, remote-state setup and migration, what the test suites cover, updated design decisions, configuration table, monitoring, troubleshooting and known limitations (mutable-tag and AL2 entries resolved). `terraform/README.md` and `CLAUDE.md` follow.

## [1.3.1] - 2026-10-18

### Fixed
- Launch-template user data used `<<EOF` with an indented body, so the script started with four spaces before `#!/bin/bash` and cloud-init could not exec it ("Exec format error"); `ECS_CLUSTER` was never written and instances would join the `default` cluster. Now `<<-EOF`, which strips the indent.
- The CodeBuild 80% coverage gate never fired: Jest prints coverage without a `%` sign, so the `grep -Po '...(?=%)'` matched nothing, `[ "" -lt 80 ]` errored, and the `if` fell through. The test file also rebuilt its own copy of the Express app, so `index.js` coverage was 0%. Tests now import the real app, Jest enforces `coverageThreshold` (80% lines, currently 81.8%) and the buildspecs run `yarn test --coverage` once instead of twice.
- `Test_App/index.js` exports the app, starts the server only when run directly and honours `PORT` (the README already documented it).
- X-Ray daemon sidecar now pulls `public.ecr.aws/xray/aws-xray-daemon:latest` instead of the untagged Docker Hub image, avoiding the Docker Hub rate limit already fixed for the Node base image in 1.0.1.

### Security
- Dockerfile installs with `yarn install --frozen-lockfile --ignore-scripts` (SonarCloud docker:S6505, docker:S8543); `index.js` uses `const` and `node:http` (javascript:S3504, S7772).

### Docs
- README: mermaid architecture and deployment-sequence diagrams, design-decisions table, known-limitations section (mutable image tags, AL2 end of support, public test listener, no HTTPS), real clone URL, six IAM roles (not five), Node 20.19+ for Vite 8, Checkov runs with `soft_fail`, branch names in tfvars do not exist in this repo, troubleshooting no longer suggests setting `privileged_mode` (already on).
- Test_App README: drops the non-existent `/health` endpoint, lists the real routes and the coverage threshold, Node prerequisite corrected from 14 to 20.19+.
- Client `index.html` title and description no longer say Create React App.

## [1.3.0] - 2026-10-13

### Changed
- Test_App client moved from Create React App (react-scripts 5) to Vite 8. Output stays in `client/build`, so `index.js`, the Dockerfile and buildspec are unchanged; the CRA `resolutions` block and boilerplate README are gone.

### Security
- Clears all 10 open Dependabot alerts: 9 came only through react-scripts (webpack-dev-server x6, braces, node-forge, sprintf-js); the server-side sprintf-js (jest -> js-yaml 3 -> argparse 1) is cut by resolving js-yaml's argparse to 2.0.1, which only its CLI uses.
- Resolve shell-quote to ^1.11.0 for a critical advisory published 2026-10-13 (via concurrently). `yarn audit` reports 0 in both Test_App and client.

## [1.2.0] - 2026-05-03

### Security / IAM
- Scoped the CodePipeline role to the services it actually uses; removed `ec2:*`, `s3:*`, `ecs:*`, `autoscaling:*`, `elasticloadbalancing:*`, `cloudwatch:*`, `opsworks:*`, `devicefarm:*`, `servicecatalog:*`, `states:*`, `appconfig:*` wildcard grants.
- Split the ECS task identity into **two distinct roles**: `EcsTaskExecutionRole` (image pull + log write) and `EcsTaskRole` (application runtime identity). The task role is now scoped to `AWSXrayWriteOnlyAccess`.
- Replaced the deprecated `inline_policy {}` block with separate `aws_iam_role_policy` resources on every role.
- Narrowed CloudWatch Logs access on the execution role from `CloudWatchLogsFullAccess` to account-scoped `logs:*` actions.
- Scoped CodeBuild report-group and ECR push actions to account-scoped ARNs.

### Tagging
- Introduced `provider.default_tags` — every taggable resource now inherits the project tag set automatically.
- Removed all per-resource `tags =` arguments and all 15 unused `variable "tags"` module declarations. The `aws_autoscaling_group`'s two `tag {}` (singular) blocks remain because AWS requires them.

### CI / tooling
- Added `.github/workflows/security-and-terraform.yml` — runs `terraform fmt -check -recursive` + `terraform validate`, AWS ASH (Docker container, findings uploaded as an artifact), and Checkov (SARIF uploaded to GitHub Code Scanning) on every push and PR.

### ECS service
- Added explicit `deployment_maximum_percent = 200` and `deployment_minimum_healthy_percent = 100` on the service to guarantee zero-downtime task rebalancing outside of CodeDeploy-driven deployments.

### Code quality
- Restructured all 33 `.tf` files with consistent `# Section` headings and one-line descriptions; trimmed verbose banner comments. Terraform codebase down ~27 % (≈ 2,800 → 2,032 lines).
- Removed redundant `depends_on` arguments that duplicated implicit module-output references.

### Docs
- Corrected README: ECS-on-EC2 (not Fargate), MIT license (not ISC), accurate variable defaults (`us-east-1`, `blue-green-dep-app`), Node.js >= 18, correct module directory name (`task_definition/`).

## [1.1.0] - 2026-02-28

- Configure Renovate for monthly grouped dependency updates

## [1.0.1] - 2025-07-26

- Swap ALB target groups to balance traffic between target_group1 and target_group2
- Add pipeline webhook triggers for automatic GitHub push detection
- Fix Docker Hub rate limit by using ECR Public Gallery for Node.js images
- Migrate from CodeCommit to GitHub: update pipeline configs, IAM roles, variables
- Update README for improved clarity

## [1.0.0] - 2025-07-26

- Initial blue-green deployment pipeline on AWS
- Terraform modules: VPC (2 AZ), ECS, ALB, CodePipeline, CodeBuild, CodeDeploy
- Canary deployment (30% for 1 min, then full cutover)
- Multi-environment pipeline: Dev, Test, Manual approval, Prod
- Express + React test app with Docker multi-stage build
- Jest + Supertest with 80% coverage gate
