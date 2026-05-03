variable "name" {
  description = "Pipeline base name."
  type        = string
}

variable "pipeline_role_arn" {
  description = "CodePipeline service role ARN."
  type        = string
}

variable "kms_key_alias" {
  description = "KMS key alias for artifact encryption."
  type        = string
}

variable "github_connection_arn" {
  description = "CodeStar Connection ARN authorizing GitHub access."
  type        = string
}

variable "github_owner" {
  description = "GitHub owner."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name."
  type        = string
}

variable "dev_branch_name" {
  description = "Branch that triggers this pipeline."
  type        = string
}

variable "artifact_bucket" {
  description = "Artifact bucket name."
  type        = string
}

variable "dev_codebuild_project_name" {
  description = "CodeBuild project invoked by the Build stage."
  type        = string
}

variable "dev_codedeploy_app_name" {
  description = "CodeDeploy application for the Deploy stage."
  type        = string
}

variable "dev_deployment_group_name" {
  description = "CodeDeploy deployment group for the Deploy stage."
  type        = string
}
