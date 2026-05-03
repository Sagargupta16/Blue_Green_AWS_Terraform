################################################################################
# IAM Module - outputs.tf
#
# Exposes the ARNs and names of every role created by this module so other
# modules (task_definition, codebuild, codedeploy, codepipeline, asg) can wire
# them without recreating the identity.
#
# NOTE: ecs_task_execution_role_arn and ecs_task_role_arn are now two
# different roles (previously both pointed at the execution role).
################################################################################


################################################################################
# ECS roles
################################################################################

output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role (used by the ECS agent to pull images & write logs)."
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task (application) role assumed by the running container at runtime."
  value       = aws_iam_role.ecs_task_role.arn
}

output "ecs_instance_role_name" {
  description = "Name of the IAM role attached to EC2 container-instances in the ASG."
  value       = aws_iam_role.ecs_instance_role.name
}


################################################################################
# CI/CD roles
################################################################################

output "codebuild_role_arn" {
  description = "ARN of the CodeBuild service role."
  value       = aws_iam_role.codebuild_role.arn
}

output "codedeploy_role_arn" {
  description = "ARN of the CodeDeploy service role used for ECS blue/green deployments."
  value       = aws_iam_role.codedeploy_role.arn
}

output "codepipeline_role_arn" {
  description = "ARN of the CodePipeline service role orchestrating Source/Build/Deploy stages."
  value       = aws_iam_role.codepipeline_role.arn
}
