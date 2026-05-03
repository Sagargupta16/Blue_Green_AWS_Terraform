variable "name" {
  description = "Base name prefix for IAM roles and policies."
  type        = string
}

variable "account_id" {
  description = "AWS account ID, used to build account-scoped ARNs."
  type        = string
}

variable "region" {
  description = "AWS region, used to build region-scoped ARNs."
  type        = string
}

variable "s3_bucket_arn" {
  description = "Artifact bucket ARN that CI/CD roles access."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS CMK ARN used for artifact encryption."
  type        = string
}

variable "codebuild_project_names" {
  description = "CodeBuild project base names the pipeline may invoke."
  type        = list(string)
  default     = []
}
