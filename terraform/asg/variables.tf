################################################################################
# ASG Module - variables.tf
################################################################################


################################################################################
# Naming & cluster linkage
################################################################################

variable "name" {
  description = "Base name for launch template, ASG, and capacity provider."
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster the instances will join."
  type        = string
}

variable "ecs_instance_role_name" {
  description = "Name of the IAM role attached to container-instances via instance profile."
  type        = string
}


################################################################################
# EC2 launch-template parameters
################################################################################

variable "asg_ec2_image_id" {
  description = "AMI ID for the ECS container-instances (resolved from SSM upstream)."
  type        = string
}

variable "asg_ec2_instance_type" {
  description = "EC2 instance type for container-instances."
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs attached to launched instances."
  type        = list(string)
}


################################################################################
# ASG sizing & placement
################################################################################

variable "asg_desired_capacity" {
  description = "Desired number of instances."
  type        = number
}

variable "asg_max_size" {
  description = "Maximum number of instances."
  type        = number
}

variable "asg_min_size" {
  description = "Minimum number of instances."
  type        = number
}

variable "private_subnets" {
  description = "Private subnet IDs the ASG may place instances in."
  type        = list(string)
}


################################################################################
# Tagging
################################################################################

variable "tags" {
  description = "Common tags applied to ASG resources."
  type        = map(string)
  default     = {}
}
