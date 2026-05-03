variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "name" {
  description = "Base name for the ALB and target groups."
  type        = string
}

variable "subnets" {
  description = "Public subnet IDs the ALB is placed in."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs attached to the ALB."
  type        = list(string)
}
