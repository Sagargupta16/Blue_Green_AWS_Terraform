variable "name" {
    description = "The name of the ECS task definition that defines how containers should run"
    type = string
}
variable "aws_region" {
    description = "The AWS region where the ECS task definition will be created and executed"
    type = string
}
variable "task_definition_image" {
    description = "The Docker image URI (including ECR repository URL and tag) for the application container"
    type = string
}
variable "task_definition_cpu" {
    description = "The number of CPU units allocated to the task definition (256, 512, 1024, 2048, 4096)"
    type = number
}
variable "task_definition_memory" {
    description = "The amount of memory (in MiB) allocated to the task definition"
    type = number
}
variable "task_definition_network_mode" {
    description = "The Docker networking mode for the task definition (bridge, host, awsvpc, none)"
    type = string
}
variable "container_port" {
    description = "The port number on which the application container listens for incoming traffic"
    type = number
}
variable "ecs_task_execution_role_arn" {
    description = "The ARN of the IAM role that ECS uses to pull images and write logs on behalf of the task"
    type = string
}
variable "ecs_task_role_arn" {
    description = "The ARN of the IAM role that the application containers can assume to access AWS services"
    type = string
}

variable "tags" {
    description = "A map of tags to assign to ECS task definition for resource management and cost tracking"
    type        = map(string)
    default     = {}
}