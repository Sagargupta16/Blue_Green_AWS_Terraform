variable "name" {
  description = "Base name of the CodeBuild project."
  type        = string
}

variable "aws_region" {
  description = "Region injected as AWS_DEFAULT_REGION."
  type        = string
}

variable "build_env" {
  description = "Logical environment (dev, main) - image tag prefix."
  type        = string
}

variable "codebuild_role_arn" {
  description = "CodeBuild service role ARN."
  type        = string
}

variable "aws_kms_alias" {
  description = "KMS key alias for artifact encryption."
  type        = string
}

variable "ecr_repository_url" {
  description = "ECR repository URL images are pushed to."
  type        = string
}

variable "task_definition_arn" {
  description = "ECS task definition ARN referenced in appspec.yml."
  type        = string
}

variable "container_name" {
  description = "Container name in appspec.yml."
  type        = string
}

variable "container_port" {
  description = "Container port in appspec.yml."
  type        = number
}
