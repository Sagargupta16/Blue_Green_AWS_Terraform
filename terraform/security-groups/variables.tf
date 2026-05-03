################################################################################
# Security Groups Module - variables.tf
################################################################################

variable "name" {
  description = "Base name used for the ALB and ECS security groups."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the security groups are created."
  type        = string
}

variable "tags" {
  description = "Common tags applied to security groups."
  type        = map(string)
  default     = {}
}
