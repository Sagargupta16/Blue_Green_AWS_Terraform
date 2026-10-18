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
  description = "CodeConnections (formerly CodeStar Connections) ARN authorizing GitHub access."
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

variable "main_branch_name" {
  description = "Production branch that triggers this pipeline."
  type        = string
}

variable "artifact_bucket" {
  description = "Artifact bucket name."
  type        = string
}

variable "test_codebuild_project_name" {
  description = "CodeBuild project invoked by the Build stage."
  type        = string
}

variable "test_codedeploy_app_name" {
  description = "CodeDeploy application for the test environment (codedeploy engine)."
  type        = string
  default     = null
}

variable "test_deployment_group_name" {
  description = "CodeDeploy deployment group for the test environment (codedeploy engine)."
  type        = string
  default     = null
}

variable "prod_codedeploy_app_name" {
  description = "CodeDeploy application for the prod environment (codedeploy engine)."
  type        = string
  default     = null
}

variable "prod_deployment_group_name" {
  description = "CodeDeploy deployment group for the prod environment (codedeploy engine)."
  type        = string
  default     = null
}

variable "deployment_engine" {
  description = "codedeploy (CodeDeployToECS action) or ecs (ECS standard action)."
  type        = string
  default     = "codedeploy"
}

variable "test_ecs_cluster_name" {
  description = "Test ECS cluster (ecs engine)."
  type        = string
  default     = null
}

variable "test_ecs_service_name" {
  description = "Test ECS service (ecs engine)."
  type        = string
  default     = null
}

variable "prod_ecs_cluster_name" {
  description = "Prod ECS cluster (ecs engine)."
  type        = string
  default     = null
}

variable "prod_ecs_service_name" {
  description = "Prod ECS service (ecs engine)."
  type        = string
  default     = null
}
