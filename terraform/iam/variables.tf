variable "name" {
  description = "Name of the IAM role"
  type = string
}
variable "account_id" {
  description = "AWS account ID"
  type = string
}
variable "region" {
  description = "AWS region"
  type = string
}
variable "s3_bucket_arn" {
  description = "S3 bucket ARN"
  type = string
}
variable "kms_key_arn" {
  description = "KMS key ARN"
  type = string
}
variable "codecommit_repo_arn" {
  description = "CodeCommit repository ARN"
  type = string
}
variable "codebuild_project_names" {
  description = "List of CodeBuild project names"
  type = list(string)
}