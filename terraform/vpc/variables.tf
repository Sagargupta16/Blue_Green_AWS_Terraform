variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
}

variable "availability_zones" {
  description = "Two AZs for the subnet pairs."
  type        = list(string)
}

variable "name" {
  description = "Prefix for the flow log group name."
  type        = string
}

variable "kms_key_arn" {
  description = "CMK that encrypts the flow log group."
  type        = string
}

variable "flow_log_role_arn" {
  description = "IAM role VPC Flow Logs assumes to write to the log group."
  type        = string
}

variable "flow_log_retention_days" {
  description = "Days the flow log group keeps its logs."
  type        = number
  default     = 365
}
