variable "name" {
    description = "The name/alias of the KMS key used for encrypting resources across the CI/CD pipeline and infrastructure"
    type = string
}

variable "tags" {
    description = "A map of tags to assign to KMS key for resource management and cost tracking"
    type        = map(string)
    default     = {}
}
