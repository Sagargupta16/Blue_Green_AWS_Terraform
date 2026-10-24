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

variable "log_bucket_name" {
  description = "Log bucket the ALB writes its access logs to."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS CMK ARN that encrypts the alarm SNS topic."
  type        = string
}


# Deployment engine

variable "deployment_engine" {
  description = "Who runs blue/green: codedeploy (CODE_DEPLOY controller) or ecs (ECS native)."
  type        = string
  default     = "codedeploy"
}

variable "ecs_deployment_strategy" {
  description = "ECS native strategy: CANARY or BLUE_GREEN. Ignored for codedeploy."
  type        = string
  default     = "CANARY"
}

variable "canary_percent" {
  description = "Share of production traffic the new version gets first (CANARY only)."
  type        = number
  default     = 30
}

variable "canary_interval_minutes" {
  description = "Minutes the canary share runs before the rest of the traffic shifts."
  type        = number
  default     = 1
}

variable "bake_time_minutes" {
  description = "Minutes blue stays up after the full shift, for a fast rollback (ECS native)."
  type        = number
  default     = 1
}

variable "ecs_infrastructure_role_arn" {
  description = "Role ECS assumes to rewrite listener rules (ECS native only)."
  type        = string
  default     = null
}


# Alarms

variable "rollback_5xx_threshold" {
  description = "Target 5xx responses per minute that roll a deployment back."
  type        = number
  default     = 5
}

variable "alarm_email" {
  description = "Email subscribed to the alarm topic; empty for none."
  type        = string
  default     = ""
}
