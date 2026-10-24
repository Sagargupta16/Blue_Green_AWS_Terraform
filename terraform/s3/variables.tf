variable "name" {
  description = "Prefix for the artifact bucket name."
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
