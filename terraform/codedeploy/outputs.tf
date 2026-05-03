output "codedeploy_app_name" {
  description = "CodeDeploy application name."
  value       = aws_codedeploy_app.my_codedeploy_app.name
}

output "codedeploy_deployment_group_name" {
  description = "CodeDeploy deployment group name."
  value       = aws_codedeploy_deployment_group.example.deployment_group_name
}

output "alb_dns_name" {
  description = "Public DNS of the environment's ALB."
  value       = module.ecs.alb_dns_name
}
