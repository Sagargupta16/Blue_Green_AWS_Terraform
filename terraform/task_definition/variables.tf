variable "name" {
    description = "Name of the ECS Task Definition"
    type = string
}
variable "aws_region" {
    description = "AWS region"
    type = string
}
variable "task_definition_image" {
    description = "Task Definition Image"
    type = string
}
variable "task_definition_cpu" {
    description = "Task Definition CPU"
    type = number
}
variable "task_definition_memory" {
    description = "Task Definition Memory"
    type = number
}
variable "task_definition_network_mode" {
    description = "Task Definition Network Mode"
    type = string
}
variable "container_port" {
    description = "Container Port"
    type = number
}
variable "ecs_task_execution_role_arn" {
    description = "ECS Task Execution Role ARN"
    type = string
}
variable "ecs_task_role_arn" {
    description = "ECS Task Role ARN"
    type = string
}