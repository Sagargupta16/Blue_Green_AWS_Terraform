# ECS roles

output "ecs_task_execution_role_arn" {
  description = "ECS task execution role ARN."
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_role_arn" {
  description = "ECS task (application) role ARN."
  value       = aws_iam_role.ecs_task_role.arn
}

output "ecs_instance_role_name" {
  description = "ECS container-instance role name."
  value       = aws_iam_role.ecs_instance_role.name
}


# CI/CD roles

output "codebuild_role_arn" {
  description = "CodeBuild role ARN."
  value       = aws_iam_role.codebuild_role.arn
}

output "codedeploy_role_arn" {
  description = "CodeDeploy role ARN."
  value       = aws_iam_role.codedeploy_role.arn
}

output "codepipeline_role_arn" {
  description = "CodePipeline role ARN."
  value       = aws_iam_role.codepipeline_role.arn
}
