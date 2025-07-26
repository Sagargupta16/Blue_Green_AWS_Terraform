variable "name" {
    description = "Name of the ECR Repository"
    type = string
}
variable "kms_key_alias" {
    description = "KMS key alias"
    type = string
}