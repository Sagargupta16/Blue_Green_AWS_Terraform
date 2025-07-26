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
  description = "List of AWS availability zones for multi-AZ deployment to ensure high availability"
  type        = list(string)
  
  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 availability zones must be provided for high availability."
  }
}

# Project Variables
variable "project_name" {
  description = "The name of the project used for resource naming and tagging across all AWS resources"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "common_tags" {
  description = "Common tags to be applied to all AWS resources for consistent resource management and cost tracking"
  type        = map(string)
  default     = {}
}

# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for the Virtual Private Cloud (VPC) network range"
  type        = string
}

# ECS Variables
## task definition
variable "task_definition_cpu" {
  description = "The number of CPU units allocated to the ECS task definition (256, 512, 1024, 2048, 4096)"
  type        = number
}

variable "task_definition_memory" {
  description = "The amount of memory (in MiB) allocated to the ECS task definition"
  type        = number
}

variable "task_definition_network_mode" {
  description = "The Docker networking mode for the ECS task definition (bridge, host, awsvpc, none)"
  type        = string
}

### ASG Variables
variable "asg_ec2_ami_name" {
  description = "The name of the Amazon Machine Image (AMI) used for Auto Scaling Group EC2 instances"
  type        = string
}

variable "asg_ec2_instance_type" {
  description = "The EC2 instance type for Auto Scaling Group instances (e.g., t3.micro, t3.small, m5.large)"
  type        = string
}

variable "asg_desired_capacity" {
  description = "The desired number of EC2 instances in the Auto Scaling Group"
  type        = number
}

variable "asg_max_size" {
  description = "The maximum number of EC2 instances allowed in the Auto Scaling Group"
  type        = number
}

variable "asg_min_size" {
  description = "The minimum number of EC2 instances required in the Auto Scaling Group"
  type        = number
}

### ECS Cluster Service Variables
variable "desired_count" {
  description = "The desired number of running tasks for the ECS service across the cluster"
  type        = number
}

variable "container_port" {
  description = "The port number on which the application container listens for incoming traffic"
  type        = number
}

# GitHub repository configuration (replacing CodeCommit)
variable "github_connection_arn" {
  description = "The ARN of the CodeStar connection for GitHub integration"
  type        = string
}

variable "github_owner" {
  description = "The GitHub username or organization that owns the repository"
  type        = string
}

variable "github_repo" {
  description = "The name of the GitHub repository"
  type        = string
}

variable "main_branch_name" {
  description = "The main production branch name of the GitHub repository used for production deployments"
  type        = string
}

variable "dev_branch_name" {
  description = "The development branch name of the GitHub repository used for development and testing deployments"
  type        = string
}