################################################################################
# Root variables.tf
#
# Values are supplied via terraform.tfvars. Validation blocks on the most
# error-prone inputs (region, AZ count, project name).
################################################################################


################################################################################
# AWS region / AZs
################################################################################

variable "aws_region" {
  description = "AWS region where every resource is created."
  type        = string

  validation {
    condition = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-central-1", "ap-southeast-1", "ap-northeast-1"
    ], var.aws_region)
    error_message = "AWS region must be one of the supported regions."
  }
}

variable "availability_zones" {
  description = "At least two AZs in the chosen region (the VPC module requires exactly two)."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 availability zones must be provided for high availability."
  }
}


################################################################################
# Project-wide naming & tagging
################################################################################

variable "project_name" {
  description = "Slug used as the prefix of every resource name. Lowercase letters, digits, and hyphens only."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "common_tags" {
  description = "Base tags applied to every resource. Merged with per-module tags in locals."
  type        = map(string)
  default     = {}
}


################################################################################
# VPC sizing
################################################################################

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}


################################################################################
# ECS task definition sizing
################################################################################

variable "task_definition_cpu" {
  description = "Task-level CPU units (256, 512, 1024, 2048, 4096)."
  type        = number
}

variable "task_definition_memory" {
  description = "Task-level memory in MiB."
  type        = number
}

variable "task_definition_network_mode" {
  description = "ECS network mode (bridge, host, awsvpc, none)."
  type        = string
}


################################################################################
# ASG / EC2 capacity
################################################################################

variable "asg_ec2_ami_name" {
  description = "SSM parameter name of the ECS-optimized AMI."
  type        = string
}

variable "asg_ec2_instance_type" {
  description = "EC2 instance type for container-instances."
  type        = string
}

variable "asg_desired_capacity" {
  description = "Desired number of EC2 instances."
  type        = number
}

variable "asg_max_size" {
  description = "Maximum number of EC2 instances."
  type        = number
}

variable "asg_min_size" {
  description = "Minimum number of EC2 instances."
  type        = number
}


################################################################################
# ECS service sizing
################################################################################

variable "desired_count" {
  description = "Desired number of running ECS tasks."
  type        = number
}

variable "container_port" {
  description = "Port the application container listens on."
  type        = number
}


################################################################################
# Source control (GitHub via CodeStar Connection)
################################################################################

variable "github_connection_arn" {
  description = "ARN of the CodeStar Connections resource authorizing GitHub access."
  type        = string
}

variable "github_owner" {
  description = "GitHub username or organization that owns the source repository."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name (without owner)."
  type        = string
}

variable "main_branch_name" {
  description = "Production branch name that triggers the main pipeline."
  type        = string
}

variable "dev_branch_name" {
  description = "Development branch name that triggers the dev pipeline."
  type        = string
}
