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

output "deployment_engine" {
  description = "Which engine runs blue/green (codedeploy or ecs)."
  value       = var.deployment_engine
}

output "rollback_alarms" {
  description = "Alarms per environment that roll back an in-flight deployment."
  value = {
    dev  = module.codedeploy_dev.rollback_alarm_names
    test = module.codedeploy_test.rollback_alarm_names
    prod = module.codedeploy_prod.rollback_alarm_names
  }
}
