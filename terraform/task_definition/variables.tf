variable "name" {
  description = "Base name for the task family."
  type        = string
}

variable "aws_region" {
  description = "Region injected into awslogs options."
  type        = string
}

variable "task_definition_image" {
  description = "Application container image URI."
  type        = string
}

variable "task_definition_cpu" {
  description = "Task-level CPU units."
  type        = number
}

variable "task_definition_memory" {
  description = "Task-level memory (MiB)."
  type        = number
}

variable "task_definition_network_mode" {
  description = "Docker network mode."
  type        = string
}

variable "container_port" {
  description = "Application container port."
  type        = number
}

variable "ecs_task_execution_role_arn" {
  description = "Execution role ARN (image pull and log write)."
  type        = string
}

variable "ecs_task_role_arn" {
  description = "Task role ARN (application runtime identity)."
  type        = string
}
