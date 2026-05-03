# Outputs

output "alb_dns_name_dev" {
  description = "Public DNS of the dev ALB."
  value       = module.codedeploy_dev.alb_dns_name
}

output "alb_dns_name_test" {
  description = "Public DNS of the test ALB."
  value       = module.codedeploy_test.alb_dns_name
}

output "alb_dns_name_prod" {
  description = "Public DNS of the prod ALB."
  value       = module.codedeploy_prod.alb_dns_name
}
