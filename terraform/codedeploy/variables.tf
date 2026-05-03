################################################################################
# CodeDeploy Module - variables.tf
################################################################################


################################################################################
# Naming & networking
################################################################################

variable "name" {
  description = "Base name (environment prefix, e.g. dev-blue-green-dep-app)."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID (forwarded to the nested ecs module)."
  type        = string
}

variable "public_subnets" {
  description = "Public subnet IDs for the ALB."
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnet IDs for ECS container-instances."
  type        = list(string)
}


################################################################################
# IAM identities
################################################################################

variable "app_task_role_arn" {
  description = "ARN of the CodeDeploy service role used for blue/green deployments."
  type        = string
}

variable "ecs_instance_role_name" {
  description = "Name of the IAM role attached to ECS container-instances."
  type        = string
}


################################################################################
# ECS task / service sizing
################################################################################

variable "task_definition_arn" {
  description = "ARN of the ECS task definition the service runs."
  type        = string
}

variable "container_name" {
  description = "Name of the container in the task definition (used by the ALB target group)."
  type        = string
}

variable "container_port" {
  description = "Port the container listens on."
  type        = number
}

variable "desired_count" {
  description = "Desired number of running ECS tasks."
  type        = number
}


################################################################################
# Underlying ASG / EC2
################################################################################

variable "asg_ec2_ami_name" {
  description = "SSM parameter name for the ECS-optimized AMI."
  type        = string
}

variable "asg_ec2_instance_type" {
  description = "EC2 instance type for container-instances."
  type        = string
}

variable "asg_desired_capacity" {
  description = "Desired number of EC2 container-instances."
  type        = number
}

variable "asg_max_size" {
  description = "Maximum number of EC2 container-instances."
  type        = number
}

variable "asg_min_size" {
  description = "Minimum number of EC2 container-instances."
  type        = number
}


################################################################################
# Shared artifact bucket
################################################################################

variable "s3_bucket_name" {
  description = "Name of the shared artifact bucket."
  type        = string
}


################################################################################
# Tagging
################################################################################

variable "tags" {
  description = "Common tags applied to CodeDeploy resources."
  type        = map(string)
  default     = {}
}
