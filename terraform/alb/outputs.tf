################################################################################
# ALB Module - outputs.tf
################################################################################


################################################################################
# Load balancer
################################################################################

output "alb_arn" {
  description = "ARN of the Application Load Balancer."
  value       = aws_lb.alb.arn
}

output "alb_name" {
  description = "Name of the Application Load Balancer."
  value       = aws_lb.alb.name
}

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer."
  value       = aws_lb.alb.dns_name
}


################################################################################
# Target groups (blue / green pair)
################################################################################

output "target_group1_name" {
  description = "Name of the first (blue) target group."
  value       = aws_lb_target_group.target_group1.name
}

output "target_group2_name" {
  description = "Name of the second (green) target group."
  value       = aws_lb_target_group.target_group2.name
}

output "target_group1_arn" {
  description = "ARN of the first (blue) target group."
  value       = aws_lb_target_group.target_group1.arn
}

output "target_group2_arn" {
  description = "ARN of the second (green) target group."
  value       = aws_lb_target_group.target_group2.arn
}


################################################################################
# Listeners (used by CodeDeploy prod/test traffic routes)
################################################################################

output "listener_port_arns" {
  description = "ARNs of the production listener (port 80). Passed to CodeDeploy prod_traffic_route."
  value       = [aws_lb_listener.http.arn]
}

output "listener_8080_port_arns" {
  description = "ARNs of the test listener (port 8080). Passed to CodeDeploy test_traffic_route."
  value       = [aws_lb_listener.http_8080.arn]
}
