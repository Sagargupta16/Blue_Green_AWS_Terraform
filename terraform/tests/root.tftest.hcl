# Whole-stack tests with mocked providers: no AWS account, no credentials.
# `command = apply` against a mock provider only fills computed values with
# fake data; nothing is created. Run from terraform/: terraform test

mock_provider "aws" {
  source = "./tests/mocks"
}
mock_provider "random" {}

# terraform.tfvars is loaded automatically; these keep the run hermetic.
variables {
  github_connection_arn = "arn:aws:codeconnections:us-east-1:111122223333:connection/00000000-0000-0000-0000-000000000000"
}

run "codedeploy_engine_is_the_default" {
  assert {
    condition     = output.deployment_engine == "codedeploy"
    error_message = "The default engine should stay codedeploy so existing stacks do not change."
  }

  assert {
    condition = alltrue([
      module.codedeploy_dev.codedeploy_deployment_group_name != null,
      module.codedeploy_test.codedeploy_deployment_group_name != null,
      module.codedeploy_prod.codedeploy_deployment_group_name != null,
    ])
    error_message = "Every environment needs a CodeDeploy deployment group with the codedeploy engine."
  }

  assert {
    condition     = module.iam.ecs_infrastructure_role_arn == null
    error_message = "The ECS infrastructure role is only for the ecs engine."
  }

  assert {
    condition     = alltrue([for env, alarms in output.rollback_alarms : length(alarms) == 2])
    error_message = "Each environment should have the 5xx and unhealthy-host rollback alarms."
  }
}

run "ecs_native_engine_drops_codedeploy" {
  variables {
    deployment_engine = "ecs"
  }

  assert {
    condition = alltrue([
      module.codedeploy_dev.codedeploy_app_name == null,
      module.codedeploy_test.codedeploy_app_name == null,
      module.codedeploy_prod.codedeploy_app_name == null,
    ])
    error_message = "The ecs engine must not create CodeDeploy applications."
  }

  assert {
    condition     = module.iam.ecs_infrastructure_role_arn != null
    error_message = "The ecs engine needs the ECS infrastructure role for listener rules."
  }

  assert {
    condition     = module.codedeploy_prod.ecs_service_name == "prod-blue-green-dep-app-service"
    error_message = "The prod service name feeds the ECS deploy action and must stay stable."
  }
}

run "rejects_unknown_engine" {
  command = plan

  variables {
    deployment_engine = "argo"
  }

  expect_failures = [var.deployment_engine]
}

run "rejects_fractional_canary_percent" {
  command = plan

  variables {
    canary_percent = 12.5
  }

  expect_failures = [var.canary_percent]
}

run "rejects_fractional_interval_and_bake_time" {
  command = plan

  variables {
    canary_interval_minutes = 1.5
    bake_time_minutes       = 0.5
  }

  expect_failures = [var.canary_interval_minutes, var.bake_time_minutes]
}

run "rejects_unknown_ecs_strategy" {
  command = plan

  variables {
    ecs_deployment_strategy = "ROLLING"
  }

  expect_failures = [var.ecs_deployment_strategy]
}
