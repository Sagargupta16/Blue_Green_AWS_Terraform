################################################################################
# CodeDeploy Module - outputs.tf
################################################################################

output "codedeploy_app_name" {
  description = "Name of the CodeDeploy application (referenced by the pipeline Deploy stage)."
  value       = aws_codedeploy_app.my_codedeploy_app.name
}

output "codedeploy_deployment_group_name" {
  description = "Name of the CodeDeploy deployment group (referenced by the pipeline Deploy stage)."
  value       = aws_codedeploy_deployment_group.example.deployment_group_name
}

output "alb_dns_name" {
  description = "Public DNS of the environment's ALB (surfaced at the root for convenience)."
  value       = module.ecs.alb_dns_name
}
