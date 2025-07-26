output "alb_dns_name_dev" {
  description = "The DNS name of the ALB for dev"
  value       = module.codedeploy_dev.alb_dns_name
}

output "alb_dns_name_test" {
  description = "The DNS name of the ALB for test"
  value       = module.codedeploy_test.alb_dns_name
}

output "alb_dns_name_prod" {
  description = "The DNS name of the ALB for prod"
  value       = module.codedeploy_prod.alb_dns_name
}