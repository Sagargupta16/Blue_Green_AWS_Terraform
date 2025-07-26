variable "name" {
  description = "The base name used for creating IAM roles and policies across the infrastructure"
  type = string
}
variable "account_id" {
  description = "The AWS account ID where IAM resources will be created and permissions will be granted"
  type = string
}
variable "region" {
  description = "The AWS region where IAM resources will operate and access regional services"
  type = string
}
variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket that IAM roles will need access to for artifacts and deployments"
  type = string
}
variable "kms_key_arn" {
  description = "The ARN of the KMS key that IAM roles will use for encryption and decryption operations"
  type = string
}
# Removed codecommit_repo_arn since we're using GitHub instead
variable "codebuild_project_names" {
  description = "List of CodeBuild project names that IAM roles will need permissions to access and execute"
  type = list(string)
}

variable "tags" {
  description = "A map of tags to assign to IAM roles and policies for resource management and cost tracking"
  type        = map(string)
  default     = {}
}