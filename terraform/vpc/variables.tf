variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
}

variable "availability_zones" {
  description = "Two AZs for the subnet pairs."
  type        = list(string)
}
