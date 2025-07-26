output "task_definition_arn" {
  description = "Task definition ARN for created task definition."
  value       = aws_ecs_task_definition.task-def.arn
}

output "container_name" {
  description = "Container name for the task definition."
  value       = local.container_name
}