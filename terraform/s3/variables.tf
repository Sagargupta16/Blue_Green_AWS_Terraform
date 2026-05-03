################################################################################
# S3 Module - variables.tf
################################################################################

variable "name" {
  description = "Name prefix for the artifact bucket (<name>-artifact-bucket-<randompet>)."
  type        = string
}

variable "tags" {
  description = "Common tags applied to the bucket."
  type        = map(string)
  default     = {}
}
