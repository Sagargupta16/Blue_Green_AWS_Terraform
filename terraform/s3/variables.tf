variable "name" {
  description = "Prefix for the artifact and log bucket names."
  type        = string
}

variable "account_id" {
  description = "AWS account ID, used to scope log delivery in the log bucket policy."
  type        = string
}

variable "region" {
  description = "AWS region, used to scope log delivery in the log bucket policy."
  type        = string
}

variable "kms_key_arn" {
  description = "CMK the artifact bucket encrypts with by default."
  type        = string
}

variable "noncurrent_version_days" {
  description = "Days an overwritten artifact version is kept before S3 expires it."
  type        = number
  default     = 30
}

variable "log_retention_days" {
  description = "Days the log bucket keeps S3 access logs, ALB access logs and VPC flow logs."
  type        = number
  default     = 90
}
