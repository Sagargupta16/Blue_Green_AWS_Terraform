# AWS Configuration
aws_region         = "us-east-1"
availability_zones = ["us-east-1a", "us-east-1b"]

# Project Configuration
project_name = "blue-green-dep-app"

# VPC Configuration
vpc_cidr = "10.0.0.0/16"

# ECS Task Definition Configuration
task_definition_cpu          = 256
task_definition_memory       = 512
task_definition_network_mode = "awsvpc"

# Auto Scaling Group Configuration
asg_ec2_ami_name      = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
asg_ec2_instance_type = "t2.large"
asg_desired_capacity  = 2
asg_max_size         = 4
asg_min_size         = 2

# ECS Service Configuration
desired_count  = 2
container_port = 3000

# GitHub Configuration (replacing CodeCommit)
github_connection_arn = "arn:aws:codestar-connections:us-east-1:822546254290:connection/9bfb5e94-5865-47b9-9f0a-bf9d9f0ed56e"
github_owner = "Sagargupta16"
github_repo  = "Blue_Green_AWS_Terraform"

# Branch Configuration
main_branch_name = "master"
dev_branch_name  = "feature/modifications"

# Common Tags Configuration
common_tags = {
  Project         = "Blue Green Deployment"
  ManagedBy      = "Terraform"
  CreatedBy     = "Sagar"
}
