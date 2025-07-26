output "aws_ecs_cluster_arn" {
  description = "The ARN of the ECS cluster"
  value       = aws_ecs_cluster.cluster.arn
}

output "target_group1_arn" {
  description = "The ARN of the first target group"
  value       = module.alb.target_group1_arn
}

output "target_group2_arn" {
  description = "The ARN of the second target group"
  value       = module.alb.target_group2_arn
}

output "target_group1_name" {
  description = "The name of the first target group"
  value       = module.alb.target_group1_name
}
output "target_group2_name" {
  description = "The name of the second target group"
  value       = module.alb.target_group2_name
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.cluster.name
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.my_ecs_service.name
}

output "alb_name" {
  description = "The name of the ALB"
  value       = module.alb.alb_name
}

output "listener_port_arns" {
  description = "The ARNs of the listener ports"
  value       = module.alb.listener_port_arns
}

output "listener_8080_port_arns" {
  description = "The ARNs of the listener ports"
  value       = module.alb.listener_8080_port_arns
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = module.alb.alb_dns_name
}