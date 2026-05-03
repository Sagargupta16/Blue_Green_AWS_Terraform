################################################################################
# Root outputs.tf
#
# Surfaces the public DNS of each environment's ALB so the user can curl the
# service after `terraform apply`.
################################################################################

output "alb_dns_name_dev" {
  description = "Public DNS of the dev environment's ALB."
  value       = module.codedeploy_dev.alb_dns_name
}

output "alb_dns_name_test" {
  description = "Public DNS of the test environment's ALB."
  value       = module.codedeploy_test.alb_dns_name
}

output "alb_dns_name_prod" {
  description = "Public DNS of the prod environment's ALB."
  value       = module.codedeploy_prod.alb_dns_name
}
