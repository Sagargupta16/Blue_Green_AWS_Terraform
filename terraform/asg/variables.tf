variable "name" {
  description = "Base name for the launch template, ASG, and capacity provider."
  type        = string
}

variable "ecs_cluster_name" {
  description = "Target ECS cluster name."
  type        = string
}

variable "ecs_instance_role_name" {
  description = "IAM role name for container-instances."
  type        = string
}

variable "asg_ec2_image_id" {
  description = "AMI ID for the launch template."
  type        = string
}

variable "asg_ec2_instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs attached to instances."
  type        = list(string)
}

variable "asg_desired_capacity" {
  description = "Desired instance count."
  type        = number
}

variable "asg_max_size" {
  description = "Maximum instance count."
  type        = number
}

variable "asg_min_size" {
  description = "Minimum instance count."
  type        = number
}

variable "private_subnets" {
  description = "Private subnet IDs for instance placement."
  type        = list(string)
}
