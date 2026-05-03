################################################################################
# IAM Module - variables.tf
#
# Inputs required to build the five IAM roles used across the pipeline and
# ECS workload. The account_id / region inputs let the module construct
# account-scoped resource ARNs (logs, ECR, CodeBuild report-groups) rather
# than falling back to `Resource = "*"`.
################################################################################


################################################################################
# Naming & context
################################################################################

variable "name" {
  description = "The base name used for creating IAM roles and policies across the infrastructure."
  type        = string
}

variable "account_id" {
  description = "The AWS account ID where IAM resources will be created and permissions will be granted."
  type        = string
}

variable "region" {
  description = "The AWS region where IAM resources will operate and access regional services."
  type        = string
}


################################################################################
# Cross-service ARNs
################################################################################

variable "s3_bucket_arn" {
  description = "ARN of the S3 artifact bucket that CI/CD roles need access to."
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS CMK used to encrypt pipeline artifacts and build outputs."
  type        = string
}

variable "codebuild_project_names" {
  description = "List of CodeBuild project base names the pipeline may invoke. Used to scope the pipeline role's codebuild:* actions."
  type        = list(string)
  default     = []
}


################################################################################
# Tagging
################################################################################

variable "tags" {
  description = "Common tags applied to all IAM resources for cost allocation and ownership."
  type        = map(string)
  default     = {}
}
