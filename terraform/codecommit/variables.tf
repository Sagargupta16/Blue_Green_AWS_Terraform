################################################################################
# CodeCommit Module - variables.tf  (DEPRECATED - kept for historical reference)
################################################################################

variable "name" {
  description = "Base name for the (unused) CodeCommit repository."
  type        = string
}

variable "tags" {
  description = "Tags for the (unused) CodeCommit repository."
  type        = map(string)
  default     = {}
}
