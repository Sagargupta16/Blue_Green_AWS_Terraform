variable "aws_region" {
  description = "Region for the state bucket (use the same region as the main stack)."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Slug used in the bucket name and tags."
  type        = string
  default     = "blue-green-dep-app"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Lowercase letters, digits, and hyphens only."
  }
}

variable "bucket_name" {
  description = "Override the bucket name. Default: <project_name>-tfstate-<account_id>."
  type        = string
  default     = null
}

variable "noncurrent_version_days" {
  description = "Days an overwritten state version is kept before S3 expires it."
  type        = number
  default     = 90
}

variable "access_log_days" {
  description = "Days the state bucket's server access logs are kept."
  type        = number
  default     = 365
}
