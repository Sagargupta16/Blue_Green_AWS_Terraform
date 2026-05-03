################################################################################
# Task Definition Module - variables.tf
################################################################################


################################################################################
# Naming & region
################################################################################

variable "name" {
  description = "Base name used for the task family and container definitions."
  type        = string
}

variable "aws_region" {
  description = "AWS region where the task definition is registered; injected into awslogs options."
  type        = string
}


################################################################################
# Container image and sizing
################################################################################

variable "task_definition_image" {
  description = "Docker image URI (ECR repository URL + tag) for the application container."
  type        = string
}

variable "task_definition_cpu" {
  description = "Task-level CPU units (256, 512, 1024, 2048, 4096)."
  type        = number
}

variable "task_definition_memory" {
  description = "Task-level memory in MiB."
  type        = number
}

variable "task_definition_network_mode" {
  description = "Docker network mode for the task (bridge, host, awsvpc, none)."
  type        = string
}

variable "container_port" {
  description = "Container port the application listens on."
  type        = number
}


################################################################################
# IAM identities
################################################################################

variable "ecs_task_execution_role_arn" {
  description = "ARN of the role the ECS agent assumes to pull images & write logs (execution role)."
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ARN of the role the application container assumes at runtime (task role)."
  type        = string
}


################################################################################
# Tagging
################################################################################

variable "tags" {
  description = "Common tags applied to the task definition."
  type        = map(string)
  default     = {}
}
