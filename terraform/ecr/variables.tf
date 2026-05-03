################################################################################
# ECR Module - variables.tf
################################################################################

variable "name" {
  description = "Name prefix of the ECR repository (<name>-ecr-repo)."
  type        = string
}

variable "kms_key_alias" {
  description = "Alias of the KMS key used to encrypt ECR images at rest."
  type        = string
}

variable "tags" {
  description = "Common tags applied to the ECR repository."
  type        = map(string)
  default     = {}
}
