# Load balancer

output "alb_arn" {
  description = "ALB ARN."
  value       = aws_lb.alb.arn
}

output "alb_name" {
  description = "ALB name."
  value       = aws_lb.alb.name
}

output "alb_dns_name" {
  description = "ALB public DNS."
  value       = aws_lb.alb.dns_name
}


# Target groups

output "target_group1_name" {
  description = "Blue target group name."
  value       = aws_lb_target_group.target_group1.name
}

output "target_group2_name" {
  description = "Green target group name."
  value       = aws_lb_target_group.target_group2.name
}

output "target_group1_arn" {
  description = "Blue target group ARN."
  value       = aws_lb_target_group.target_group1.arn
}

output "target_group2_arn" {
  description = "Green target group ARN."
  value       = aws_lb_target_group.target_group2.arn
}


# Listeners

output "listener_port_arns" {
  description = "Port 80 listener ARNs (prod traffic route)."
  value       = [aws_lb_listener.http.arn]
}

output "listener_8080_port_arns" {
  description = "Port 8080 listener ARNs (test traffic route)."
  value       = [aws_lb_listener.http_8080.arn]
}


# Metric dimensions (CloudWatch uses the ARN suffix, not the full ARN)

output "alb_arn_suffix" {
  description = "ALB ARN suffix for CloudWatch dimensions."
  value       = aws_lb.alb.arn_suffix
}

output "target_group_arn_suffixes" {
  description = "Blue and green target group ARN suffixes for CloudWatch dimensions."
  value       = [aws_lb_target_group.target_group1.arn_suffix, aws_lb_target_group.target_group2.arn_suffix]
}


# Listener rules (null unless create_listener_rules)

output "production_listener_rule_arn" {
  description = "Port 80 listener rule ARN that ECS native blue/green rewrites."
  value       = one(aws_lb_listener_rule.production[*].arn)
}

output "test_listener_rule_arn" {
  description = "Port 8080 listener rule ARN that ECS native blue/green rewrites."
  value       = one(aws_lb_listener_rule.test[*].arn)
}
