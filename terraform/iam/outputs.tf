output "ecs_task_execution_role_arn" {
  description = "The ARN of the ECS task execution role"
  value       = aws_iam_role.app_task_execution_role.arn
}

output "ecs_task_role_arn" {
  description = "The ARN of the ECS task role"
  value       = aws_iam_role.app_task_execution_role.arn
}

output "codebuild_role_arn" {
  description = "The ARN of the codebuild role"
  value       = aws_iam_role.codebuild_role.arn
}

output "codedeploy_role_arn" {
  description = "The ARN of the codedeploy role"
  value       = aws_iam_role.codedeploy_role.arn
}

output "codepipeline_role_arn" {
  description = "The ARN of the codepipeline role"
  value       = aws_iam_role.codepipeline_role.arn
}

output "ecs_instance_role_name" {
  description = "The name of the ECS instance role"
  value       = aws_iam_role.ecs_instance_role.name
}