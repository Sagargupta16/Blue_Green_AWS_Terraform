# AWS Configuration
aws_region         = "us-west-2"
availability_zones = ["us-west-2a", "us-west-2b"]

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

# CodeCommit Branch Configuration
main_branch_name = "main"
dev_branch_name  = "dev"
