variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
}

variable "availability_zones" {
  description = "Two AZs for the subnet pairs."
  type        = list(string)
}

variable "flow_log_bucket_arn" {
  description = "ARN of the S3 bucket the VPC flow logs are delivered to."
  type        = string
}
