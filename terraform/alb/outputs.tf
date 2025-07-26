output "alb_arn" {
  description = "The ARN of the ALB"
  value       = aws_lb.alb.arn
}

output "alb_name" {
  description = "The name of the ALB"
  value       = aws_lb.alb.name
}

output "target_group1_name" {
  description = "The name of the first target group"
  value       = aws_lb_target_group.target_group1.name
}

output "target_group2_name" {
  description = "The name of the second target group"
  value       = aws_lb_target_group.target_group2.name
}

output "target_group1_arn" {
  description = "The ARN of the first target group"
  value       = aws_lb_target_group.target_group1.arn
}

output "target_group2_arn" {
  description = "The ARN of the second target group"
  value       = aws_lb_target_group.target_group2.arn
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.alb.dns_name
}

output "listener_port_arns" {
  description = "The ARN of the listener"
  value       = [aws_lb_listener.http.arn]
}

output "listener_8080_port_arns" {
  description = "The ARN of the listener"
  value       = [aws_lb_listener.http_8080.arn]
}