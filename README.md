# Blue-Green Deployment with AWS Terraform

Infrastructure-as-Code for a multi-environment Blue/Green deployment pipeline on AWS. A single `terraform apply` provisions the network, registry, CI/CD, and three isolated ECS environments (dev, test, prod) for a containerized Node.js reference app.

## 🏗️ Architecture Overview

- **ECS on EC2** — containerized application hosting with an Auto Scaling Group of container-instances (one cluster per environment)
- **Application Load Balancer** — per-environment ALB with two target groups (blue/green) and two listeners (`:80` prod traffic, `:8080` test traffic)
- **Auto Scaling Group + ECS Capacity Provider** — managed-scaling EC2 capacity for each cluster
- **CodePipeline (V2)** — two pipelines (`dev`, `main`) triggered by GitHub push via a CodeStar Connection
- **CodeBuild** — Docker image build, Jest test execution, 80 % coverage gate, ECR push
- **CodeDeploy** — ECS blue/green with a custom `TimeBasedCanary` config (30 % traffic for 1 min, then full cutover) and automatic rollback on failure
- **ECR** — KMS-encrypted image registry with scan-on-push
- **VPC** — 2-AZ network, 2 public subnets, 2 private subnets, 2 NAT gateways
- **IAM** — five scoped roles (instance / task execution / task / codebuild / codedeploy / codepipeline)
- **KMS** — single symmetric CMK (key rotation on) shared by S3, ECR, CodeBuild, CodePipeline, CodeDeploy
- **S3** — artifact bucket for CodeBuild/CodePipeline

## 🚀 Features

- ✅ **Zero-downtime deployments** via CodeDeploy ECS blue/green (canary rollout + auto-rollback)
- ✅ **Build-once, promote** main pipeline (same artifact goes through test → manual-approval → prod)
- ✅ **Per-environment isolation** — dev, test, and prod each get their own ECS cluster, ALB, and ASG
- ✅ **KMS-encrypted artifacts end-to-end** (S3, ECR, CodeBuild, CodePipeline, CodeDeploy)
- ✅ **Least-privilege IAM** — pipeline role scoped to the services it actually uses (no `ec2:*` / `s3:*` wildcards); execution role and task role are separate identities
- ✅ **Consistent tagging** via `provider.default_tags` — no per-resource `tags =` plumbing
- ✅ **IMDSv2 enforced** on EC2 container-instances
- ✅ **X-Ray distributed tracing** (daemon sidecar + SDK middleware)
- ✅ **CI-side security scanning** — GitHub Actions workflow runs ASH (Automated Security Helper) + Checkov + `terraform fmt/validate` on every PR
- ✅ **Dependency hygiene** — Renovate monthly grouped updates, SonarCloud connected mode

## 📋 Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.1.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with credentials for the target account
- [Docker](https://www.docker.com/get-started) for local testing and image builds
- [Node.js](https://nodejs.org/) >= 18 (the Dockerfile uses Node 24; the reference app's React deps target Node 18+)
- [Yarn](https://yarnpkg.com/) package manager
- A **CodeStar Connection** to GitHub, authorized in the AWS console — its ARN is supplied via `github_connection_arn` in `terraform.tfvars`

## 🛠️ Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Blue_Green_AWS_Terraform
   ```

2. **Configure AWS credentials**
   ```bash
   aws configure
   ```

3. **Customize variables**
   Edit `terraform/terraform.tfvars` — at minimum set `github_connection_arn`, `github_owner`, `github_repo`, `main_branch_name`, `dev_branch_name`.

4. **Initialize Terraform**
   ```bash
   cd terraform
   terraform init
   ```

> **State backend:** this project currently uses local state (`terraform/terraform.tfstate`). Do **not** use this layout for production. Move state to an S3 backend with a DynamoDB lock table, and never commit state files (they can contain secrets).

## 🚀 Usage

### Deploy Infrastructure

```bash
cd terraform
terraform plan
terraform apply
terraform output          # prints the three ALB DNS names (dev / test / prod)
```

### Deploy Application

Pushes to the configured branches trigger the pipelines automatically:

- **dev branch** → `dev` pipeline → deploys to `dev` environment
- **main branch** → `main` pipeline → builds once → deploys to `test` → manual approval → deploys to `prod`

```bash
git push origin <dev_branch_name>   # or main_branch_name
```

The manual approval step happens in the CodePipeline console.

### Local Development (reference app)

```bash
cd Test_App
yarn all-install     # installs backend + frontend, builds React client
yarn start           # starts Express on port 3000
yarn test            # Jest + Supertest
```

The app is available at <http://localhost:3000>.

## 📁 Project Structure

```
├── terraform/                    # Infrastructure as Code
│   ├── main.tf                   # Root module wiring
│   ├── variables.tf              # Input variables (validated)
│   ├── outputs.tf                # ALB DNS outputs per environment
│   ├── locals.tf                 # common_tags merged into provider default_tags
│   ├── data.tf                   # aws_caller_identity
│   ├── versions.tf               # Terraform + AWS provider pins, default_tags
│   ├── terraform.tfvars          # Your environment-specific values
│   ├── vpc/                      # VPC, subnets, IGW, NAT gateways, route tables
│   ├── security-groups/          # ALB & ECS security groups
│   ├── alb/                      # Per-env ALB + blue/green target groups + listeners
│   ├── asg/                      # Launch template + ASG + capacity provider
│   ├── ecs/                      # Per-env cluster + service + CW alarm (wraps alb/asg/security-groups)
│   ├── task_definition/          # ECS task definitions (app + X-Ray sidecar)
│   ├── codebuild/                # CodeBuild project (one per build env)
│   ├── codedeploy/               # CodeDeploy app + deployment group (one per env)
│   ├── codepipeline_dev/         # Dev pipeline (Source → Build → Deploy-Dev)
│   ├── codepipeline_main/        # Main pipeline (Source → Build → Deploy-Test → Approval → Deploy-Prod)
│   ├── ecr/                      # Private ECR repo (KMS-encrypted, scan-on-push)
│   ├── iam/                      # All IAM roles & inline policies
│   ├── kms/                      # Pipeline KMS CMK + alias
│   ├── s3/                       # Artifact bucket
│   └── codecommit/               # Deprecated (GitHub replaced CodeCommit in v1.0.1)
├── Test_App/                     # Express + React reference application
│   ├── buildspec.yml             # CodeBuild spec (alternate — the repo-root one is the active one)
│   ├── Dockerfile                # Multi-stage (client builder → server)
│   ├── index.js                  # Express backend with X-Ray SDK
│   ├── package.json
│   ├── client/                   # React (Create React App) frontend
│   └── tests/                    # Jest + Supertest
├── .github/
│   ├── workflows/
│   │   └── security-and-terraform.yml   # ASH + Checkov + terraform fmt/validate
│   ├── CODEOWNERS
│   └── pull_request_template.md
├── buildspec.yml                 # Active CodeBuild spec (referenced by CodeBuild projects)
├── renovate.json                 # Monthly grouped dep updates
├── CHANGELOG.md
├── SECURITY.md
└── README.md
```

## ⚙️ Configuration

### Key Variables (defaults from `terraform/terraform.tfvars`)

| Variable | Description | Current value |
|---|---|---|
| `aws_region` | AWS region | `us-east-1` |
| `project_name` | Resource-name prefix | `blue-green-dep-app` |
| `vpc_cidr` | VPC CIDR | `10.0.0.0/16` |
| `availability_zones` | AZ pair for the subnets | `["us-east-1a", "us-east-1b"]` |
| `asg_ec2_instance_type` | Container-instance type | `t2.large` |
| `asg_desired_capacity` / `min` / `max` | ASG sizing | `2 / 2 / 4` |
| `task_definition_cpu` / `memory` | Task sizing | `256 / 512` |
| `container_port` | App port | `3000` |
| `main_branch_name` / `dev_branch_name` | GitHub branches that trigger the pipelines | `master` / `feature/modifications` |
| `github_connection_arn` | ARN of the CodeStar Connection to GitHub | _set in tfvars_ |

### Tagging

All tags are applied once at the provider level via `default_tags`:

```hcl
provider "aws" {
  region = var.aws_region
  default_tags { tags = local.common_tags }
}
```

Modules do **not** accept or forward a `tags` variable — every taggable AWS resource inherits the project tag set automatically. The only exception is the `aws_autoscaling_group`'s `tag {}` blocks, which AWS requires as a distinct construct.

## 🔄 Blue-Green Deployment Flow

```
git push
   │
   ▼   (CodeStar Connection webhook, V2 pipeline trigger)
CodePipeline
   ├─ Source    – pull repository → S3 artifact (KMS-encrypted)
   ├─ Build     – CodeBuild: docker build, yarn test --coverage (≥ 80 %), push to ECR
   └─ Deploy    – CodeDeploy ECS blue/green:
                   1. register new task set on idle (green) target group
                   2. route test traffic via ALB :8080 for verification
                   3. shift 30 % prod traffic (:80) for 1 minute (canary)
                   4. shift remaining 70 %
                   5. drain and terminate blue task set
                   6. auto-rollback on DEPLOYMENT_FAILURE
```

## 🧪 Testing

```bash
cd Test_App
yarn test             # Jest + Supertest
yarn test --coverage  # coverage report (CodeBuild gates on ≥ 80 %)
```

## 🔍 Monitoring

- **CloudWatch Logs** — auto-created per task (app + X-Ray sidecar streams)
- **CloudWatch Metrics** — ECS ContainerInsights enabled on every cluster
- **CloudWatch Alarm** — `CPUReservation ≥ 60 %` (note: `alarm_actions = []` — wire to SNS to make actionable)
- **ALB health checks** — `GET /` every 30 s per target group
- **X-Ray** — distributed tracing via the `aws-xray-daemon` sidecar + SDK middleware in the app

## 🔐 Security

- **Scoped IAM** — CodePipeline role is scoped to the services it actually invokes (CodeStar Connections, CodeBuild, CodeDeploy, S3 artifact bucket, ECR describe, KMS, PassRole). The ECS task-execution role is distinct from the task role so image-pull and log-write are separated from application-level permissions.
- **IMDSv2 required** on the EC2 launch template.
- **KMS key rotation** enabled on the pipeline CMK.
- **ECR image scanning** on push.
- **ALB** — deletion protection, invalid-header drop.
- **CI security scanning** — every push and PR runs:
  - `terraform fmt -check -recursive` + `terraform validate`
  - AWS ASH (Automated Security Helper) — Docker image, aggregates Bandit, Checkov, cdk-nag, cfn-nag, detect-secrets, Semgrep, grype, syft, npm-audit
  - Checkov standalone — SARIF output uploaded to GitHub Code Scanning

## 🚨 Troubleshooting

1. **Terraform state lock** — `terraform force-unlock <lock-id>`
2. **Pipeline stuck at Source** — the CodeStar Connection status must be **Available**; re-authorize it in the AWS console if it is **Pending**.
3. **CodeBuild failing on `dockerd`** — the buildspec starts the Docker daemon manually. If it hangs, set `privileged_mode = true` on the CodeBuild project (the documented-supported path).
4. **ECR push rejected with `ImageTagAlreadyExistsException`** — only happens if you switch the repository to `IMMUTABLE` without removing the `:<env>-latest` tag push from `buildspec.yml`.
5. **CodeDeploy rollback** — CodeDeploy rolls back automatically on `DEPLOYMENT_FAILURE`. To force a manual rollback, stop the deployment from the CodeDeploy console.

## 🤝 Contributing

1. Fork and create a feature branch (`git checkout -b feature/my-change`)
2. Commit your changes (`git commit -m 'Describe the change'`)
3. Push the branch (`git push origin feature/my-change`)
4. Open a Pull Request — the GitHub Actions workflow will run Terraform checks and security scans automatically.

## 📝 License

MIT License — see the [LICENSE](LICENSE) file.

## 👥 Authors

- Sagar Gupta — [@Sagargupta16](https://github.com/Sagargupta16)

## 🙏 Acknowledgments

- AWS documentation and reference architectures
- Terraform community modules
- Blue/Green deployment patterns popularized by the CodeDeploy-on-ECS integration
