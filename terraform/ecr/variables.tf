variable "name" {
  description = "Prefix for the ECR repository name."
  type        = string
}

variable "kms_key_alias" {
  description = "KMS key alias for image encryption."
  type        = string
}
