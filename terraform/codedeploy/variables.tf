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

variable "kms_key_arn" {
  description = "KMS CMK ARN that encrypts the alarm SNS topic."
  type        = string
}

variable "alarm_email" {
  description = "Email subscribed to the alarm topic; empty for none."
  type        = string
  default     = ""
}

variable "deployment_engine" {
  description = "codedeploy or ecs (see the root variable)."
  type        = string
  default     = "codedeploy"
}

variable "ecs_deployment_strategy" {
  description = "ECS native strategy: CANARY or BLUE_GREEN."
  type        = string
  default     = "CANARY"
}

variable "canary_percent" {
  description = "Share of production traffic the new version gets first."
  type        = number
  default     = 30
}

variable "canary_interval_minutes" {
  description = "Minutes the canary share runs before the full shift."
  type        = number
  default     = 1
}

variable "bake_time_minutes" {
  description = "Minutes blue stays up after the full shift."
  type        = number
  default     = 1
}

variable "ecs_infrastructure_role_arn" {
  description = "Role ECS assumes to rewrite listener rules (ecs engine only)."
  type        = string
  default     = null
}
