variable "aws_region" {
    description = "AWS Region"
    type = string
}
variable "name" {
    description = "Name of the CodeBuild Project"
    type = string
}
variable "codebuild_role_arn" {
    description = "CodeBuild Role ARN"
    type = string
}
variable "ecr_repository_url" {
    description = "ECR Repository URL"
    type = string
}
variable "task_definition_arn" {
    description = "Task Definition ARN"
    type = string
}
variable "container_name" {
    description = "Container Name"
    type = string
}
variable "container_port" {
    description = "Container Port"
    type = number
}
variable "aws_kms_alias" {
    description = "AWS KMS Alias"
    type = string
}
variable "build_env" {
    description = "Build Environment"
    type = string
}