################################################################################
# ALB Module - variables.tf
################################################################################

variable "vpc_id" {
  description = "ID of the VPC where the ALB is deployed."
  type        = string
}

variable "name" {
  description = "Base name for the ALB and its target groups."
  type        = string
}

variable "subnets" {
  description = "Public subnet IDs (at least two AZs) where the ALB is placed."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs attached to the ALB."
  type        = list(string)
}

variable "tags" {
  description = "Common tags applied to ALB resources."
  type        = map(string)
  default     = {}
}
