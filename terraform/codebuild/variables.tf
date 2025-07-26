variable "aws_region" {
    description = "The AWS region where CodeBuild resources will be created"
    type = string
}
variable "name" {
    description = "The name of the CodeBuild project used for building and testing the application"
    type = string
}
variable "codebuild_role_arn" {
    description = "The ARN of the IAM role that CodeBuild will assume to access AWS services"
    type = string
}
variable "ecr_repository_url" {
    description = "The URL of the Amazon ECR repository where Docker images will be pushed"
    type = string
}
variable "task_definition_arn" {
    description = "The ARN of the ECS task definition that will be updated during deployment"
    type = string
}
variable "container_name" {
    description = "The name of the container in the ECS task definition that will be updated"
    type = string
}
variable "container_port" {
    description = "The port number on which the application container listens for incoming traffic"
    type = number
}
variable "aws_kms_alias" {
    description = "The alias of the KMS key used for encrypting CodeBuild artifacts and logs"
    type = string
}
variable "build_env" {
    description = "The build environment specification for CodeBuild (e.g., development, staging, production)"
    type = string
}

variable "tags" {
    description = "A map of tags to assign to CodeBuild resources for resource management and cost tracking"
    type        = map(string)
    default     = {}
}