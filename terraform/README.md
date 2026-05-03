# terraform

Root module. Provisions a full multi-environment Blue/Green ECS-on-EC2 delivery
pipeline (network, registry, IAM, KMS, artifact bucket, per-environment ECS
clusters, two CodePipelines) in a single `terraform apply`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.1.0 |
| aws       | ~> 6.0  |
| random    | ~> 3.1  |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 6.0 |

## Modules

| Name | Source | Purpose |
|------|--------|---------|
| s3                | ./s3                | Artifact bucket (KMS-encrypted) |
| vpc               | ./vpc               | VPC, subnets, IGW, NAT gateways, route tables |
| kms               | ./kms               | Customer-managed CMK + alias (rotation on) |
| ecr               | ./ecr               | Private image repository (KMS-encrypted, scan-on-push) |
| iam               | ./iam               | All roles and inline policies |
| task_definition_dev    | ./task_definition   | ECS task definition for dev builds |
| task_definition_main   | ./task_definition   | ECS task definition for main (test + prod) |
| codebuild_dev     | ./codebuild         | CodeBuild project for dev branch |
| codebuild_main    | ./codebuild         | CodeBuild project for main branch |
| codedeploy_dev    | ./codedeploy        | Dev environment (ECS cluster + ALB + CodeDeploy app) |
| codedeploy_test   | ./codedeploy        | Test environment (ECS cluster + ALB + CodeDeploy app) |
| codedeploy_prod   | ./codedeploy        | Prod environment (ECS cluster + ALB + CodeDeploy app) |
| codepipeline_dev  | ./codepipeline_dev  | Dev pipeline: Source → Build → Deploy-Dev |
| codepipeline_main | ./codepipeline_main | Main pipeline: Source → Build → Deploy-Test → Approval → Deploy-Prod |

## Resources

| Name | Type |
|------|------|
| aws_autoscaling_group                 | resource |
| aws_cloudwatch_metric_alarm           | resource |
| aws_codebuild_project                 | resource |
| aws_codedeploy_app                    | resource |
| aws_codedeploy_deployment_config      | resource |
| aws_codedeploy_deployment_group       | resource |
| aws_codepipeline                      | resource |
| aws_ecr_repository                    | resource |
| aws_ecs_capacity_provider             | resource |
| aws_ecs_cluster                       | resource |
| aws_ecs_cluster_capacity_providers    | resource |
| aws_ecs_service                       | resource |
| aws_ecs_task_definition               | resource |
| aws_eip                               | resource |
| aws_iam_instance_profile              | resource |
| aws_iam_role                          | resource |
| aws_iam_role_policy                   | resource |
| aws_iam_role_policy_attachment        | resource |
| aws_internet_gateway                  | resource |
| aws_kms_alias                         | resource |
| aws_kms_key                           | resource |
| aws_launch_template                   | resource |
| aws_lb                                | resource |
| aws_lb_listener                       | resource |
| aws_lb_target_group                   | resource |
| aws_nat_gateway                       | resource |
| aws_route_table                       | resource |
| aws_route_table_association           | resource |
| aws_s3_bucket                         | resource |
| aws_security_group                    | resource |
| aws_security_group_rule               | resource |
| aws_subnet                            | resource |
| aws_vpc                               | resource |
| random_pet                            | resource |
| aws_caller_identity                   | data source |
| aws_kms_alias                         | data source |
| aws_ssm_parameter                     | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region                   | AWS region. Must be one of the supported regions listed in the validation rule. | `string`        | n/a          | yes |
| availability_zones           | At least two AZs for the subnets.                                               | `list(string)`  | n/a          | yes |
| project_name                 | Lowercase slug used as the prefix for every resource name.                      | `string`        | n/a          | yes |
| common_tags                  | Base tags merged into the provider's `default_tags`.                            | `map(string)`   | `{}`         | no  |
| vpc_cidr                     | CIDR block for the VPC.                                                         | `string`        | n/a          | yes |
| task_definition_cpu          | Task-level CPU units.                                                           | `number`        | n/a          | yes |
| task_definition_memory       | Task-level memory in MiB.                                                       | `number`        | n/a          | yes |
| task_definition_network_mode | ECS task network mode.                                                          | `string`        | n/a          | yes |
| asg_ec2_ami_name             | SSM parameter name for the ECS-optimized AMI.                                   | `string`        | n/a          | yes |
| asg_ec2_instance_type        | EC2 instance type for container-instances.                                      | `string`        | n/a          | yes |
| asg_desired_capacity         | Desired EC2 instance count per environment.                                     | `number`        | n/a          | yes |
| asg_max_size                 | Maximum EC2 instance count per environment.                                     | `number`        | n/a          | yes |
| asg_min_size                 | Minimum EC2 instance count per environment.                                     | `number`        | n/a          | yes |
| desired_count                | Desired running ECS task count per service.                                     | `number`        | n/a          | yes |
| container_port               | Application container port.                                                     | `number`        | n/a          | yes |
| github_connection_arn        | ARN of the CodeStar Connection authorizing GitHub access.                       | `string`        | n/a          | yes |
| github_owner                 | GitHub owner / org.                                                             | `string`        | n/a          | yes |
| github_repo                  | GitHub repository name.                                                         | `string`        | n/a          | yes |
| main_branch_name             | Branch that triggers the main (test + prod) pipeline.                           | `string`        | n/a          | yes |
| dev_branch_name              | Branch that triggers the dev pipeline.                                          | `string`        | n/a          | yes |

## Outputs

| Name | Description |
|------|-------------|
| alb_dns_name_dev  | Public DNS of the dev ALB.  |
| alb_dns_name_test | Public DNS of the test ALB. |
| alb_dns_name_prod | Public DNS of the prod ALB. |

<!-- END_TF_DOCS -->

## Example `terraform.tfvars`

```hcl
aws_region         = "us-east-1"
availability_zones = ["us-east-1a", "us-east-1b"]

project_name = "blue-green-dep-app"
vpc_cidr     = "10.0.0.0/16"

task_definition_cpu          = 256
task_definition_memory       = 512
task_definition_network_mode = "awsvpc"

asg_ec2_ami_name      = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
asg_ec2_instance_type = "t2.large"
asg_desired_capacity  = 2
asg_max_size          = 4
asg_min_size          = 2

desired_count  = 2
container_port = 3000

github_connection_arn = "arn:aws:codestar-connections:us-east-1:<account>:connection/<id>"
github_owner          = "Sagargupta16"
github_repo           = "Blue_Green_AWS_Terraform"
main_branch_name      = "master"
dev_branch_name       = "feature/modifications"

common_tags = {
  Project   = "Blue Green Deployment"
  ManagedBy = "Terraform"
  CreatedBy = "Sagar"
}
```

## Usage

```bash
terraform init
terraform fmt -recursive -check
terraform validate
terraform plan
terraform apply
terraform output          # ALB DNS names for dev / test / prod
```

## Module Layout

```
terraform/
├── main.tf              # wires all modules
├── variables.tf         # root inputs (validated)
├── outputs.tf           # per-env ALB DNS outputs
├── locals.tf            # common_tags
├── data.tf              # aws_caller_identity
├── versions.tf          # provider + version pins, default_tags
├── terraform.tfvars     # your values
│
├── vpc/                 # network
├── security-groups/     # ALB + ECS SGs
├── alb/                 # ALB + listeners + target groups
├── asg/                 # launch template + ASG + capacity provider
├── ecs/                 # cluster + service + CW alarm (wraps alb/asg/security-groups)
├── task_definition/     # ECS task definition (app + X-Ray sidecar)
│
├── ecr/                 # image repository
├── kms/                 # pipeline CMK + alias
├── s3/                  # artifact bucket
├── iam/                 # all roles and inline policies
│
├── codebuild/           # CodeBuild project
├── codedeploy/          # CodeDeploy app + deployment group (wraps ecs/)
├── codepipeline_dev/    # dev CodePipeline
├── codepipeline_main/   # main CodePipeline
└── codecommit/          # DEPRECATED: source moved to GitHub in v1.0.1
```

## Tagging Model

Tags are applied once at the provider level. Modules neither accept nor
forward a `tags` variable.

```hcl
provider "aws" {
  region = var.aws_region
  default_tags { tags = local.common_tags }
}
```

Only exception: the `aws_autoscaling_group`'s singular `tag {}` blocks,
which AWS requires as a distinct construct (not the `tags` argument).

## Notes

- **State backend:** local state is used by default. For production, migrate
  to an S3 backend with a DynamoDB lock table; do not commit state files.
- **CodeDeploy compatibility:** `aws_ecs_service` uses
  `deployment_controller { type = "CODE_DEPLOY" }`, so
  `deployment_circuit_breaker` cannot be set. Zero-downtime rebalancing
  outside of CodeDeploy-driven deployments is handled via
  `deployment_maximum_percent = 200` and
  `deployment_minimum_healthy_percent = 100`.
- **Branch pins:** the dev pipeline triggers on `dev_branch_name`; the main
  pipeline triggers on `main_branch_name` and promotes the same artifact
  through test → manual approval → prod.
