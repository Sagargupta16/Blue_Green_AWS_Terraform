################################################################################
# ECS Module - variables.tf
################################################################################


################################################################################
# Naming & networking
################################################################################

variable "name" {
  description = "Base name used for the ECS cluster, service, ALB, and ASG."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where ECS resources are deployed."
  type        = string
}

variable "public_subnets" {
  description = "Public subnet IDs where the ALB is placed."
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnet IDs where container-instances and tasks run."
  type        = list(string)
}


################################################################################
# ASG / EC2 capacity
################################################################################

variable "asg_ec2_ami_name" {
  description = "SSM parameter name for the ECS-optimized AMI (e.g. /aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id)."
  type        = string
}

variable "asg_ec2_instance_type" {
  description = "EC2 instance type for ECS container-instances."
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
# ECS service / task
################################################################################

variable "desired_count" {
  description = "Desired number of running ECS tasks."
  type        = number
}

variable "container_name" {
  description = "Name of the application container in the task definition."
  type        = string
}

variable "container_port" {
  description = "Port the application container listens on."
  type        = number
}

variable "task_definition_arn" {
  description = "ARN of the ECS task definition the service runs."
  type        = string
}


################################################################################
# External identities & shared buckets
################################################################################

variable "ecs_instance_role_name" {
  description = "Name of the IAM role attached to container-instances via instance profile."
  type        = string
}

variable "s3_bucket_name" {
  description = "Artifact bucket name (passed through for parity with codedeploy module)."
  type        = string
}


################################################################################
# Tagging
################################################################################

variable "tags" {
  description = "Common tags applied to ECS resources."
  type        = map(string)
  default     = {}
}
