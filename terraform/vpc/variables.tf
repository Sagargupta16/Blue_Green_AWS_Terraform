################################################################################
# VPC Module - variables.tf
################################################################################

variable "vpc_cidr" {
  description = "CIDR block for the Virtual Private Cloud (VPC). Subnets are derived by cidrsubnet(cidr, 8, n)."
  type        = string
}

variable "availability_zones" {
  description = "Exactly two AZ names used for the public and private subnet pairs."
  type        = list(string)
}

variable "tags" {
  description = "Common tags applied to all VPC resources."
  type        = map(string)
  default     = {}
}
