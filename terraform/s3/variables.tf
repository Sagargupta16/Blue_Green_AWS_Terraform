variable "name" {
    description = "The name of the S3 bucket used for storing CI/CD pipeline artifacts, deployment packages, and build outputs"
    type = string
}

variable "tags" {
    description = "A map of tags to assign to S3 bucket for resource management and cost tracking"
    type        = map(string)
    default     = {}
}