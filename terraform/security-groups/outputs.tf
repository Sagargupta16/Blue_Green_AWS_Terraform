################################################################################
# Security Groups Module - outputs.tf
################################################################################

output "alb_security_group_id" {
  description = "ID of the ALB security group."
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  description = "ID of the ECS security group."
  value       = aws_security_group.ecs.id
}
