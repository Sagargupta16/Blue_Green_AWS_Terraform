################################################################################
# ECS Module - outputs.tf
################################################################################


################################################################################
# Cluster & service
################################################################################

output "aws_ecs_cluster_arn" {
  description = "ARN of the ECS cluster."
  value       = aws_ecs_cluster.cluster.arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  value       = aws_ecs_cluster.cluster.name
}

output "ecs_service_name" {
  description = "Name of the ECS service."
  value       = aws_ecs_service.my_ecs_service.name
}


################################################################################
# ALB pass-through (consumed by CodeDeploy module)
################################################################################

output "alb_name" {
  description = "Name of the environment's ALB."
  value       = module.alb.alb_name
}

output "alb_dns_name" {
  description = "Public DNS of the environment's ALB."
  value       = module.alb.alb_dns_name
}

output "target_group1_arn" {
  description = "ARN of the blue target group."
  value       = module.alb.target_group1_arn
}

output "target_group2_arn" {
  description = "ARN of the green target group."
  value       = module.alb.target_group2_arn
}

output "target_group1_name" {
  description = "Name of the blue target group."
  value       = module.alb.target_group1_name
}

output "target_group2_name" {
  description = "Name of the green target group."
  value       = module.alb.target_group2_name
}

output "listener_port_arns" {
  description = "Production listener ARNs (port 80) - used by CodeDeploy prod_traffic_route."
  value       = module.alb.listener_port_arns
}

output "listener_8080_port_arns" {
  description = "Test listener ARNs (port 8080) - used by CodeDeploy test_traffic_route."
  value       = module.alb.listener_8080_port_arns
}
