# Changelog

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
