variable "name" {
    description = "Name of the CodePipeline"
    type = string
}
variable "pipeline_role_arn" {
    description = "ARN of the IAM role for CodePipeline"
    type = string
}
variable "artifact_bucket" {
    description = "S3 bucket for storing artifacts"
    type = string
}
variable "codecommit_repository_name" {
    description = "Name of the CodeCommit repository"
    type = string
}
variable "main_branch_name" {
    description = "Name of the main branch"
    type = string
}
variable "test_codebuild_project_name" {
    description = "Name of the CodeBuild project for testing"
    type = string
}
variable "test_codedeploy_app_name" {
    description = "Name of the CodeDeploy application for testing"
    type = string
}
variable "test_deployment_group_name" {
    description = "Name of the deployment group for testing"
    type = string
}
variable "prod_codedeploy_app_name" {
    description = "Name of the CodeDeploy application for production"
    type = string
}
variable "prod_deployment_group_name" {
    description = "Name of the deployment group for production"
    type = string
}
variable "kms_key_alias" {
    description = "KMS key alias"
    type = string
}