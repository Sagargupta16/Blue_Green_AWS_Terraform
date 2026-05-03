output "task_definition_arn" {
  description = "Task definition ARN."
  value       = aws_ecs_task_definition.task_def.arn
}

output "container_name" {
  description = "Application container name."
  value       = local.container_name
}
