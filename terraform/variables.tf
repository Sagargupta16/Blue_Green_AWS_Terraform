# Aws Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  
  validation {
    condition = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-central-1", "ap-southeast-1", "ap-northeast-1"
    ], var.aws_region)
    error_message = "AWS region must be a valid region."
  }
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  
  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 availability zones must be provided for high availability."
  }
}

# Project Variables
variable "project_name" {
  description = "Project name"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

# ECS Variables
## task definition
variable "task_definition_cpu" {
  description = "The number of cpu units used by the task definition"
  type        = number
}

variable "task_definition_memory" {
  description = "The amount of memory used by the task definition"
  type        = number
}

variable "task_definition_network_mode" {
  description = "The network mode used by the task definition"
  type        = string
}

### ASG Variables
variable "asg_ec2_ami_name" {
  description = "The name of the AMI used by the ASG EC2 instances"
  type        = string
}

variable "asg_ec2_instance_type" {
  description = "The instance type of the ASG EC2 instances"
  type        = string
}

variable "asg_desired_capacity" {
  description = "The desired capacity of the ASG"
  type        = number
}

variable "asg_max_size" {
  description = "The maximum size of the ASG"
  type        = number
}

variable "asg_min_size" {
  description = "The minimum size of the ASG"
  type        = number
}

### ECS Cluster Service Variables
variable "desired_count" {
  description = "The desired count of the ECS service"
  type        = number
}

variable "container_port" {
  description = "The port of the container"
  type        = number
}

variable "main_branch_name" {
  description = "The branch name of the CodeCommit repository"
  type        = string
}

variable "dev_branch_name" {
  description = "The branch name of the CodeCommit repository"
  type        = string
}