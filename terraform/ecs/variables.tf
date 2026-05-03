variable "name" {
  description = "Base name for the ECS cluster, service, and nested resources."
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
  description = "Private subnet IDs for tasks and container-instances."
  type        = list(string)
}

variable "asg_ec2_ami_name" {
  description = "SSM parameter name for the ECS-optimized AMI."
  type        = string
}

variable "asg_ec2_instance_type" {
  description = "EC2 instance type for container-instances."
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

variable "desired_count" {
  description = "Desired running task count."
  type        = number
}

variable "container_name" {
  description = "Application container name."
  type        = string
}

variable "container_port" {
  description = "Application container port."
  type        = number
}

variable "task_definition_arn" {
  description = "ECS task definition ARN."
  type        = string
}

variable "ecs_instance_role_name" {
  description = "IAM role name for container-instances."
  type        = string
}

variable "s3_bucket_name" {
  description = "Shared artifact bucket name."
  type        = string
}
