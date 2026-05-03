# Cluster & service

output "aws_ecs_cluster_arn" {
  description = "ECS cluster ARN."
  value       = aws_ecs_cluster.cluster.arn
}

output "ecs_cluster_name" {
  description = "ECS cluster name."
  value       = aws_ecs_cluster.cluster.name
}

output "ecs_service_name" {
  description = "ECS service name."
  value       = aws_ecs_service.my_ecs_service.name
}


# ALB pass-through

output "alb_name" {
  description = "ALB name."
  value       = module.alb.alb_name
}

output "alb_dns_name" {
  description = "ALB public DNS."
  value       = module.alb.alb_dns_name
}

output "target_group1_arn" {
  description = "Blue target group ARN."
  value       = module.alb.target_group1_arn
}

output "target_group2_arn" {
  description = "Green target group ARN."
  value       = module.alb.target_group2_arn
}

output "target_group1_name" {
  description = "Blue target group name."
  value       = module.alb.target_group1_name
}

output "target_group2_name" {
  description = "Green target group name."
  value       = module.alb.target_group2_name
}

output "listener_port_arns" {
  description = "Port 80 listener ARNs (prod)."
  value       = module.alb.listener_port_arns
}

output "listener_8080_port_arns" {
  description = "Port 8080 listener ARNs (test)."
  value       = module.alb.listener_8080_port_arns
}
