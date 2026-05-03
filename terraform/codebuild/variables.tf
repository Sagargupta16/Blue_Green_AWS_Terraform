################################################################################
# CodeBuild Module - variables.tf
################################################################################


################################################################################
# Naming & region
################################################################################

variable "name" {
  description = "Base name of the CodeBuild project."
  type        = string
}

variable "aws_region" {
  description = "Region injected into the build environment as AWS_DEFAULT_REGION."
  type        = string
}

variable "build_env" {
  description = "Logical environment name (e.g. dev, main). Exposed as the build_env env variable and used as the image-tag prefix."
  type        = string
}


################################################################################
# IAM & crypto
################################################################################

variable "codebuild_role_arn" {
  description = "ARN of the IAM service role CodeBuild assumes."
  type        = string
}

variable "aws_kms_alias" {
  description = "KMS key alias used to encrypt CodeBuild artifacts."
  type        = string
}


################################################################################
# Deployment targets / image
################################################################################

variable "ecr_repository_url" {
  description = "URL of the ECR repository the build pushes images to."
  type        = string
}

variable "task_definition_arn" {
  description = "ARN of the ECS task definition referenced by the generated appspec.yml."
  type        = string
}

variable "container_name" {
  description = "Name of the container in the task definition (used in appspec.yml)."
  type        = string
}

variable "container_port" {
  description = "Container port (used in appspec.yml)."
  type        = number
}


################################################################################
# Tagging
################################################################################

variable "tags" {
  description = "Common tags applied to the CodeBuild project."
  type        = map(string)
  default     = {}
}
