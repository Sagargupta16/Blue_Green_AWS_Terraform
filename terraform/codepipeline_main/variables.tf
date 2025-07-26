variable "name" {
    description = "The name of the main CodePipeline used for production environment CI/CD automation"
    type = string
}
variable "pipeline_role_arn" {
    description = "The ARN of the IAM role that CodePipeline will assume to orchestrate the production CI/CD process"
    type = string
}
variable "artifact_bucket" {
    description = "The name of the S3 bucket used for storing pipeline artifacts between production stages"
    type = string
}
variable "codecommit_repository_name" {
    description = "The name of the CodeCommit repository containing the application source code"
    type = string
}
variable "main_branch_name" {
    description = "The name of the main production branch that triggers the production pipeline"
    type = string
}
variable "test_codebuild_project_name" {
    description = "The name of the CodeBuild project responsible for testing before production deployment"
    type = string
}
variable "test_codedeploy_app_name" {
    description = "The name of the CodeDeploy application used for staging/test environment deployments"
    type = string
}
variable "test_deployment_group_name" {
    description = "The name of the CodeDeploy deployment group for staging/test environment targets"
    type = string
}
variable "prod_codedeploy_app_name" {
    description = "The name of the CodeDeploy application used for production environment deployments"
    type = string
}
variable "prod_deployment_group_name" {
    description = "The name of the CodeDeploy deployment group for production environment targets"
    type = string
}
variable "kms_key_alias" {
    description = "The alias of the KMS key used for encrypting production pipeline artifacts and outputs"
    type = string
}

variable "tags" {
    description = "A map of tags to assign to production CodePipeline resources for resource management and cost tracking"
    type        = map(string)
    default     = {}
}