# Changelog

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
