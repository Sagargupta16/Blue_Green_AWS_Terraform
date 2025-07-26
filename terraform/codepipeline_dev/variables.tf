variable "name" {
    description = "The name of the CodePipeline used for development environment CI/CD automation"
    type = string
}
variable "pipeline_role_arn" {
    description = "The ARN of the IAM role that CodePipeline will assume to orchestrate the CI/CD process"
    type = string
}
variable "artifact_bucket" {
    description = "The name of the S3 bucket used to store pipeline artifacts between stages"
    type = string
}
variable "github_connection_arn" {
    description = "The ARN of the CodeStar connection for GitHub integration"
    type = string
}
variable "github_owner" {
    description = "The GitHub username or organization that owns the repository"
    type = string
}
variable "github_repo" {
    description = "The name of the GitHub repository containing the application source code"
    type = string
}
variable "dev_branch_name" {
    description = "The name of the development branch that triggers the development pipeline"
    type = string
}
variable "dev_codebuild_project_name" {
    description = "The name of the CodeBuild project responsible for building and testing in development"
    type = string
}
variable "dev_codedeploy_app_name" {
    description = "The name of the CodeDeploy application used for development environment deployments"
    type = string
}
variable "dev_deployment_group_name" {
    description = "The name of the CodeDeploy deployment group for development environment targets"
    type = string
}
variable "kms_key_alias" {
    description = "The alias of the KMS key used for encrypting pipeline artifacts and build outputs"
    type = string
}

variable "tags" {
    description = "A map of tags to assign to development CodePipeline resources for resource management and cost tracking"
    type        = map(string)
    default     = {}
}