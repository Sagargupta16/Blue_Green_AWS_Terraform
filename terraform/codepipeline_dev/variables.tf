variable "name" {
    description = "Name of the CodePipeline"
    type = string
}
variable "pipeline_role_arn" {
    description = "ARN of the IAM role for CodePipeline"
    type = string
}
variable "artifact_bucket" {
    description = "S3 bucket to store artifacts"
    type = string
}
variable "codecommit_repository_name" {
    description = "Name of the CodeCommit repository"
    type = string
}
variable "dev_branch_name" {
    description = "Name of the development branch"
    type = string
}
variable "dev_codebuild_project_name" {
    description = "Name of the CodeBuild project for development"
    type = string
}
variable "dev_codedeploy_app_name" {
    description = "Name of the CodeDeploy application for development"
    type = string
}
variable "dev_deployment_group_name" {
    description = "Name of the deployment group for development"
    type = string
}
variable "kms_key_alias" {
    description = "KMS key alias"
    type = string
}