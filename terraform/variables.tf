# Region & AZs

variable "aws_region" {
  description = "AWS region."
  type        = string

  validation {
    condition = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-central-1", "ap-southeast-1", "ap-northeast-1"
    ], var.aws_region)
    error_message = "Unsupported AWS region."
  }
}

variable "availability_zones" {
  description = "At least two AZs."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "Provide at least 2 availability zones."
  }
}


# Project

variable "project_name" {
  description = "Slug prefix for every resource name."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Lowercase letters, digits, and hyphens only."
  }
}

variable "common_tags" {
  description = "Base tags merged into provider default_tags."
  type        = map(string)
  default     = {}
}


# VPC

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
}


# ECS task sizing

variable "task_definition_cpu" {
  description = "Task-level CPU units."
  type        = number
}

variable "task_definition_memory" {
  description = "Task-level memory (MiB)."
  type        = number
}

variable "task_definition_network_mode" {
  description = "ECS network mode."
  type        = string
}


# ASG

variable "asg_ec2_ami_name" {
  description = "SSM parameter name for the ECS-optimized AMI."
  type        = string
}

variable "asg_ec2_instance_type" {
  description = "EC2 instance type for container-instances."
  type        = string
}

variable "asg_desired_capacity" {
  description = "Desired EC2 instance count."
  type        = number
}

variable "asg_max_size" {
  description = "Maximum EC2 instance count."
  type        = number
}

variable "asg_min_size" {
  description = "Minimum EC2 instance count."
  type        = number
}


# ECS service

variable "desired_count" {
  description = "Desired running task count."
  type        = number
}

variable "container_port" {
  description = "Application container port."
  type        = number
}


# Source control (GitHub via CodeConnections, formerly CodeStar Connections)

variable "github_connection_arn" {
  description = "CodeConnections (formerly CodeStar Connections) ARN authorizing GitHub access."
  type        = string
}

variable "github_owner" {
  description = "GitHub owner."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name."
  type        = string
}

variable "main_branch_name" {
  description = "Production branch."
  type        = string
}

variable "dev_branch_name" {
  description = "Development branch."
  type        = string
}


# Deployment engine

variable "deployment_engine" {
  description = "Who runs blue/green: codedeploy (CodeDeploy + CODE_DEPLOY controller) or ecs (ECS native blue/green, no CodeDeploy)."
  type        = string
  default     = "codedeploy"

  validation {
    condition     = contains(["codedeploy", "ecs"], var.deployment_engine)
    error_message = "deployment_engine must be codedeploy or ecs."
  }
}

variable "ecs_deployment_strategy" {
  description = "ECS native strategy when deployment_engine = ecs: CANARY (shift canary_percent first) or BLUE_GREEN (all at once)."
  type        = string
  default     = "CANARY"

  validation {
    condition     = contains(["CANARY", "BLUE_GREEN"], var.ecs_deployment_strategy)
    error_message = "ecs_deployment_strategy must be CANARY or BLUE_GREEN."
  }
}

variable "canary_percent" {
  description = "Share of production traffic the new version gets first (both engines)."
  type        = number
  default     = 30

  validation {
    condition     = var.canary_percent >= 1 && var.canary_percent <= 99 && floor(var.canary_percent) == var.canary_percent
    error_message = "canary_percent must be a whole number from 1 to 99 (CodeDeploy only takes integers)."
  }
}

variable "canary_interval_minutes" {
  description = "Minutes the canary share runs before the rest of the traffic shifts."
  type        = number
  default     = 1

  validation {
    condition     = var.canary_interval_minutes >= 1 && var.canary_interval_minutes <= 1440 && floor(var.canary_interval_minutes) == var.canary_interval_minutes
    error_message = "canary_interval_minutes must be a whole number from 1 to 1440."
  }
}

variable "bake_time_minutes" {
  description = "Minutes the old (blue) version stays up after the full shift, so a rollback is instant."
  type        = number
  default     = 1

  validation {
    condition     = var.bake_time_minutes >= 0 && var.bake_time_minutes <= 1440 && floor(var.bake_time_minutes) == var.bake_time_minutes
    error_message = "bake_time_minutes must be a whole number from 0 to 1440."
  }
}


# Alarms

variable "alarm_email" {
  description = "Email subscribed to every environment's alarm topic (confirm the AWS mail once). Empty for none."
  type        = string
  default     = ""
}
