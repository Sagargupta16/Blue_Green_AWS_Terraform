################################################################################
# Task Definition Module - outputs.tf
################################################################################

output "task_definition_arn" {
  description = "ARN of the registered ECS task definition (family and revision)."
  value       = aws_ecs_task_definition.task_def.arn
}

output "container_name" {
  description = "Name of the application container inside the task definition (used by the ALB target group and CodeDeploy appspec)."
  value       = local.container_name
}
