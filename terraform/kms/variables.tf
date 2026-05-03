################################################################################
# KMS Module - variables.tf
################################################################################

variable "name" {
  description = "Base name used for the KMS key and its alias (alias/<name>-kms-key)."
  type        = string
}

variable "tags" {
  description = "Common tags applied to KMS resources."
  type        = map(string)
  default     = {}
}
