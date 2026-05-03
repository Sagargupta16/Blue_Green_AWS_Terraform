################################################################################
# CodePipeline (Main) Module - variables.tf
################################################################################


################################################################################
# Naming
################################################################################

variable "name" {
  description = "Base name of the production pipeline (environment prefix)."
  type        = string
}


################################################################################
# IAM & crypto
################################################################################

variable "pipeline_role_arn" {
  description = "ARN of the IAM service role the pipeline assumes."
  type        = string
}

variable "kms_key_alias" {
  description = "Alias of the KMS key used to encrypt pipeline artifacts."
  type        = string
}


################################################################################
# Source (GitHub via CodeStar Connection)
################################################################################

variable "github_connection_arn" {
  description = "ARN of the CodeStar Connections resource authorizing GitHub access."
  type        = string
}

variable "github_owner" {
  description = "GitHub user or organization that owns the repository."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name (without owner)."
  type        = string
}

variable "main_branch_name" {
  description = "Production branch that triggers this pipeline."
  type        = string
}


################################################################################
# Artifact store & downstream actions
################################################################################

variable "artifact_bucket" {
  description = "Name of the shared S3 artifact bucket."
  type        = string
}

variable "test_codebuild_project_name" {
  description = "Name of the CodeBuild project invoked by the Build stage."
  type        = string
}

variable "test_codedeploy_app_name" {
  description = "Name of the CodeDeploy application for the test environment."
  type        = string
}

variable "test_deployment_group_name" {
  description = "Name of the CodeDeploy deployment group for the test environment."
  type        = string
}

variable "prod_codedeploy_app_name" {
  description = "Name of the CodeDeploy application for the production environment."
  type        = string
}

variable "prod_deployment_group_name" {
  description = "Name of the CodeDeploy deployment group for the production environment."
  type        = string
}


################################################################################
# Tagging
################################################################################

variable "tags" {
  description = "Common tags applied to pipeline resources."
  type        = map(string)
  default     = {}
}
