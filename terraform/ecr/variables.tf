variable "name" {
    description = "The name of the Amazon ECR repository used for storing Docker container images"
    type = string
}
variable "kms_key_alias" {
    description = "The alias of the KMS key used for encrypting ECR repository images"
    type = string
}

variable "tags" {
    description = "A map of tags to assign to ECR repository for resource management and cost tracking"
    type        = map(string)
    default     = {}
}