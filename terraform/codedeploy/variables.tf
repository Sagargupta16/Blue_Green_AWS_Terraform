variable "name" {
  description = "Environment prefix (e.g. dev-<project>)."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "public_subnets" {
  description = "Public subnet IDs for the ALB."
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnet IDs for container-instances."
  type        = list(string)
}

variable "app_task_role_arn" {
  description = "CodeDeploy service role ARN."
  type        = string
}

variable "ecs_instance_role_name" {
  description = "IAM role name for container-instances."
  type        = string
}

variable "task_definition_arn" {
  description = "ECS task definition ARN."
  type        = string
}

variable "container_name" {
  description = "Application container name."
  type        = string
}

variable "container_port" {
  description = "Container port."
  type        = number
}

variable "desired_count" {
  description = "Desired running task count."
  type        = number
}

variable "asg_ec2_ami_name" {
  description = "SSM parameter name for the ECS-optimized AMI."
  type        = string
}

variable "asg_ec2_instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "asg_desired_capacity" {
  description = "Desired container-instance count."
  type        = number
}

variable "asg_max_size" {
  description = "Maximum container-instance count."
  type        = number
}

variable "asg_min_size" {
  description = "Minimum container-instance count."
  type        = number
}

variable "s3_bucket_name" {
  description = "Shared artifact bucket name."
  type        = string
}
