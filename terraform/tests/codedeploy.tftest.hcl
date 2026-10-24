# CodeDeploy module: the canary rolls back on alarms, and the whole CodeDeploy
# layer disappears for the ecs engine.

mock_provider "aws" {
  source          = "./tests/mocks"
  override_during = plan
}

variables {
  name                   = "test-app"
  vpc_id                 = "vpc-0123456789abcdef0"
  public_subnets         = ["subnet-0000000000000000a", "subnet-0000000000000000b"]
  private_subnets        = ["subnet-0000000000000000c", "subnet-0000000000000000d"]
  app_task_role_arn      = "arn:aws:iam::111122223333:role/test-app-CodedeployRole"
  ecs_instance_role_name = "test-app-EcsInstanceRole"
  task_definition_arn    = "arn:aws:ecs:us-east-1:111122223333:task-definition/test-app:1"
  container_name         = "test-app-container"
  container_port         = 3000
  desired_count          = 2
  asg_ec2_ami_name       = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
  asg_ec2_instance_type  = "t3.large"
  asg_desired_capacity   = 2
  asg_max_size           = 4
  asg_min_size           = 2
  s3_bucket_name         = "test-app-artifacts"
  log_bucket_name        = "test-app-logs"
  kms_key_arn            = "arn:aws:kms:us-east-1:111122223333:key/00000000-0000-0000-0000-000000000000"
}

run "canary_rolls_back_on_alarm" {
  command = plan

  module {
    source = "./codedeploy"
  }

  assert {
    condition     = aws_codedeploy_deployment_group.example[0].alarm_configuration[0].enabled
    error_message = "The deployment group must watch the rollback alarms."
  }

  assert {
    condition     = aws_codedeploy_deployment_group.example[0].alarm_configuration[0].alarms == toset(["test-app-Target-5XX", "test-app-Unhealthy-Hosts"])
    error_message = "The deployment group must watch both rollback alarms."
  }

  assert {
    condition     = contains(aws_codedeploy_deployment_group.example[0].auto_rollback_configuration[0].events, "DEPLOYMENT_STOP_ON_ALARM")
    error_message = "An alarm that stops the deployment must also roll it back."
  }

  assert {
    condition = alltrue([
      aws_codedeploy_deployment_config.custom_bluegreen_config[0].traffic_routing_config[0].time_based_canary[0].percentage == 30,
      aws_codedeploy_deployment_config.custom_bluegreen_config[0].traffic_routing_config[0].time_based_canary[0].interval == 1,
    ])
    error_message = "Default canary should stay 30% for 1 minute."
  }
}

run "canary_follows_the_variables" {
  command = plan

  module {
    source = "./codedeploy"
  }

  variables {
    canary_percent          = 10
    canary_interval_minutes = 5
  }

  assert {
    condition     = aws_codedeploy_deployment_config.custom_bluegreen_config[0].traffic_routing_config[0].time_based_canary[0].percentage == 10
    error_message = "canary_percent should drive the CodeDeploy canary."
  }

  assert {
    condition     = aws_codedeploy_deployment_config.custom_bluegreen_config[0].traffic_routing_config[0].time_based_canary[0].interval == 5
    error_message = "canary_interval_minutes should drive the CodeDeploy canary."
  }
}

run "ecs_engine_has_no_codedeploy" {
  command = plan

  module {
    source = "./codedeploy"
  }

  variables {
    deployment_engine           = "ecs"
    ecs_infrastructure_role_arn = "arn:aws:iam::111122223333:role/test-app-EcsInfrastructureRole"
  }

  assert {
    condition = (
      length(aws_codedeploy_app.my_codedeploy_app) == 0 &&
      length(aws_codedeploy_deployment_config.custom_bluegreen_config) == 0 &&
      length(aws_codedeploy_deployment_group.example) == 0
    )
    error_message = "The ecs engine must not create any CodeDeploy resources."
  }

  assert {
    condition     = output.ecs_service_name == "test-app-service"
    error_message = "The service name is what the ECS deploy action targets."
  }
}
