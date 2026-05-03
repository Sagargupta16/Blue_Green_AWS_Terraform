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


# Source control (GitHub via CodeStar Connection)

variable "github_connection_arn" {
  description = "CodeStar Connection ARN authorizing GitHub access."
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
