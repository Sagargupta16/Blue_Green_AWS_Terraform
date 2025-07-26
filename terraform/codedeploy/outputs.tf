output "codedeploy_app_name" {
  description = "The name of the codedeploy app"
  value       = aws_codedeploy_app.my_codedeploy_app.name
}

output "codedeploy_deployment_group_name" {
  description = "The name of the codedeploy deployment group"
  value       = aws_codedeploy_deployment_group.example.deployment_group_name
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = module.ecs.alb_dns_name
}