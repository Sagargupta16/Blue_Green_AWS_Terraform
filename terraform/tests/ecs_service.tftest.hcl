# ECS module: the service is wired for whichever engine runs blue/green, and
# both engines get the same rollback alarms.
#
# These runs use `command = plan` with mock values applied during plan: a
# mocked apply regenerates the service's computed load_balancer block and
# drops advanced_configuration, which would test the mock, not this module.

mock_provider "aws" {
  source          = "./tests/mocks"
  override_during = plan
}

variables {
  name                   = "test-app"
  vpc_id                 = "vpc-0123456789abcdef0"
  public_subnets         = ["subnet-0000000000000000a", "subnet-0000000000000000b"]
  private_subnets        = ["subnet-0000000000000000c", "subnet-0000000000000000d"]
  asg_ec2_ami_name       = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
  asg_ec2_instance_type  = "t3.large"
  asg_desired_capacity   = 2
  asg_max_size           = 4
  asg_min_size           = 2
  desired_count          = 2
  container_name         = "test-app-container"
  container_port         = 3000
  task_definition_arn    = "arn:aws:ecs:us-east-1:111122223333:task-definition/test-app:1"
  ecs_instance_role_name = "test-app-EcsInstanceRole"
  s3_bucket_name         = "test-app-artifacts"
  kms_key_arn            = "arn:aws:kms:us-east-1:111122223333:key/00000000-0000-0000-0000-000000000000"
}

# Distinct ARNs for blue and green so the assertions can tell them apart.
override_resource {
  target          = module.alb.aws_lb_target_group.target_group2
  override_during = plan
  values = {
    arn        = "arn:aws:elasticloadbalancing:us-east-1:111122223333:targetgroup/green/0123456789abcdef"
    arn_suffix = "targetgroup/green/0123456789abcdef"
  }
}

run "codedeploy_controller" {
  command = plan

  module {
    source = "./ecs"
  }

  assert {
    condition     = aws_ecs_service.my_ecs_service.deployment_controller[0].type == "CODE_DEPLOY"
    error_message = "The codedeploy engine needs the CODE_DEPLOY controller."
  }

  assert {
    condition     = length(aws_ecs_service.my_ecs_service.alarms) == 0 && length(aws_ecs_service.my_ecs_service.deployment_circuit_breaker) == 0
    error_message = "Circuit breaker and service alarms are not allowed with CODE_DEPLOY."
  }

  assert {
    condition     = module.alb.production_listener_rule_arn == null && module.alb.test_listener_rule_arn == null
    error_message = "CodeDeploy swaps listeners, so no weighted listener rules should exist."
  }

  assert {
    condition     = toset(output.rollback_alarm_names) == toset(["test-app-Target-5XX", "test-app-Unhealthy-Hosts"])
    error_message = "Both rollback alarms must exist for the codedeploy engine too."
  }
}

run "ecs_native_canary" {
  command = plan

  module {
    source = "./ecs"
  }

  variables {
    deployment_engine           = "ecs"
    ecs_infrastructure_role_arn = "arn:aws:iam::111122223333:role/test-app-EcsInfrastructureRole"
  }

  assert {
    condition     = aws_ecs_service.my_ecs_service.deployment_controller[0].type == "ECS"
    error_message = "ECS native blue/green needs the ECS controller."
  }

  assert {
    condition     = aws_ecs_service.my_ecs_service.deployment_configuration[0].strategy == "CANARY"
    error_message = "Default ECS strategy should be CANARY to mirror the CodeDeploy canary."
  }

  assert {
    condition     = aws_ecs_service.my_ecs_service.deployment_configuration[0].canary_configuration[0].canary_percent == 30
    error_message = "Canary should start at 30% like the CodeDeploy TimeBasedCanary."
  }

  assert {
    condition = one([
      for lb in aws_ecs_service.my_ecs_service.load_balancer :
      lb.advanced_configuration[0].alternate_target_group_arn
    ]) == "arn:aws:elasticloadbalancing:us-east-1:111122223333:targetgroup/green/0123456789abcdef"
    error_message = "The alternate (green) target group must be target group 2."
  }

  assert {
    condition = one([
      for lb in aws_ecs_service.my_ecs_service.load_balancer :
      lb.advanced_configuration[0].production_listener_rule
    ]) == module.alb.production_listener_rule_arn
    error_message = "ECS must shift traffic on the port 80 listener rule."
  }

  assert {
    condition     = aws_ecs_service.my_ecs_service.deployment_circuit_breaker[0].rollback
    error_message = "The circuit breaker should roll back failed deployments."
  }

  assert {
    condition     = aws_ecs_service.my_ecs_service.alarms[0].rollback && toset(aws_ecs_service.my_ecs_service.alarms[0].alarm_names) == toset(output.rollback_alarm_names)
    error_message = "The service must roll back on both rollback alarms."
  }
}

run "ecs_native_blue_green_has_no_canary_block" {
  command = plan

  module {
    source = "./ecs"
  }

  variables {
    deployment_engine           = "ecs"
    ecs_deployment_strategy     = "BLUE_GREEN"
    ecs_infrastructure_role_arn = "arn:aws:iam::111122223333:role/test-app-EcsInfrastructureRole"
  }

  assert {
    condition     = length(aws_ecs_service.my_ecs_service.deployment_configuration[0].canary_configuration) == 0
    error_message = "BLUE_GREEN shifts all traffic at once; a canary block would be rejected."
  }
}

run "alarms_notify_the_topic" {
  command = plan

  module {
    source = "./ecs"
  }

  variables {
    alarm_email = "oncall@example.com"
  }

  assert {
    condition = alltrue([
      aws_cloudwatch_metric_alarm.target_5xx.alarm_actions == toset([aws_sns_topic.alarms.arn]),
      aws_cloudwatch_metric_alarm.unhealthy_hosts.alarm_actions == toset([aws_sns_topic.alarms.arn]),
      aws_cloudwatch_metric_alarm.ecs-alert_High-CPUReservation.alarm_actions == toset([aws_sns_topic.alarms.arn]),
    ])
    error_message = "Every alarm should notify the environment's SNS topic."
  }

  assert {
    condition     = aws_sns_topic.alarms.kms_master_key_id == var.kms_key_arn
    error_message = "The alarm topic must be encrypted with the project CMK."
  }

  assert {
    condition     = aws_sns_topic_subscription.alarm_email[0].endpoint == "oncall@example.com"
    error_message = "alarm_email should subscribe to the topic."
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.target_5xx.dimensions["LoadBalancer"] == module.alb.alb_arn_suffix
    error_message = "The 5xx alarm must watch this environment's ALB."
  }
}
