output "codedeploy_app_name" {
  description = "CodeDeploy application name (null for the ecs engine)."
  value       = one(aws_codedeploy_app.my_codedeploy_app[*].name)
}

output "codedeploy_deployment_group_name" {
  description = "CodeDeploy deployment group name (null for the ecs engine)."
  value       = one(aws_codedeploy_deployment_group.example[*].deployment_group_name)
}

output "alb_dns_name" {
  description = "Public DNS of the environment's ALB."
  value       = module.ecs.alb_dns_name
}

output "ecs_cluster_name" {
  description = "ECS cluster name (the ECS deploy action targets it for the ecs engine)."
  value       = module.ecs.ecs_cluster_name
}

output "ecs_service_name" {
  description = "ECS service name."
  value       = module.ecs.ecs_service_name
}

output "rollback_alarm_names" {
  description = "CloudWatch alarms that roll back an in-flight deployment."
  value       = module.ecs.rollback_alarm_names
}

output "alarm_topic_arn" {
  description = "SNS topic for this environment's alarms."
  value       = module.ecs.alarm_topic_arn
}
