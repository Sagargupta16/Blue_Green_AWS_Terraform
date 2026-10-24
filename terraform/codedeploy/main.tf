# Nested ECS stack (per environment)

module "ecs" {
  source                 = "../ecs"
  name                   = var.name
  public_subnets         = var.public_subnets
  vpc_id                 = var.vpc_id
  asg_ec2_ami_name       = var.asg_ec2_ami_name
  asg_ec2_instance_type  = var.asg_ec2_instance_type
  asg_desired_capacity   = var.asg_desired_capacity
  asg_max_size           = var.asg_max_size
  asg_min_size           = var.asg_min_size
  container_name         = var.container_name
  container_port         = var.container_port
  private_subnets        = var.private_subnets
  desired_count          = var.desired_count
  ecs_instance_role_name = var.ecs_instance_role_name
  task_definition_arn    = var.task_definition_arn
  s3_bucket_name         = var.s3_bucket_name
  log_bucket_name        = var.log_bucket_name
  kms_key_arn            = var.kms_key_arn
  alarm_email            = var.alarm_email

  deployment_engine           = var.deployment_engine
  ecs_deployment_strategy     = var.ecs_deployment_strategy
  canary_percent              = var.canary_percent
  canary_interval_minutes     = var.canary_interval_minutes
  bake_time_minutes           = var.bake_time_minutes
  ecs_infrastructure_role_arn = var.ecs_infrastructure_role_arn
}


# CodeDeploy is only created for deployment_engine = "codedeploy". With
# "ecs" the service runs native blue/green and these resources go away.

locals {
  codedeploy = var.deployment_engine == "codedeploy" ? 1 : 0
}

# Addresses gained [0] when count was added; keep existing state.
moved {
  from = aws_codedeploy_app.my_codedeploy_app
  to   = aws_codedeploy_app.my_codedeploy_app[0]
}

moved {
  from = aws_codedeploy_deployment_config.custom_bluegreen_config
  to   = aws_codedeploy_deployment_config.custom_bluegreen_config[0]
}

moved {
  from = aws_codedeploy_deployment_group.example
  to   = aws_codedeploy_deployment_group.example[0]
}


# CodeDeploy application & deployment config

resource "aws_codedeploy_app" "my_codedeploy_app" {
  count = local.codedeploy

  name             = "${var.name}-app"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_config" "custom_bluegreen_config" {
  count = local.codedeploy

  compute_platform       = "ECS"
  deployment_config_name = "${var.name}-bluegreen-config"

  traffic_routing_config {
    type = "TimeBasedCanary"
    time_based_canary {
      interval   = var.canary_interval_minutes
      percentage = var.canary_percent
    }
  }
}


# Deployment group (blue/green)

resource "aws_codedeploy_deployment_group" "example" {
  count = local.codedeploy

  app_name               = aws_codedeploy_app.my_codedeploy_app[0].name
  deployment_config_name = aws_codedeploy_deployment_config.custom_bluegreen_config[0].deployment_config_name
  deployment_group_name  = "${var.name}-deploy-grp"
  service_role_arn       = var.app_task_role_arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
  }

  # A 5xx spike or an unhealthy target during the canary stops the
  # deployment, and DEPLOYMENT_STOP_ON_ALARM above sends traffic back to blue.
  alarm_configuration {
    enabled = true
    alarms  = module.ecs.rollback_alarm_names
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = var.bake_time_minutes
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = module.ecs.ecs_cluster_name
    service_name = module.ecs.ecs_service_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = module.ecs.listener_port_arns
      }

      target_group {
        name = module.ecs.target_group1_name
      }

      target_group {
        name = module.ecs.target_group2_name
      }

      test_traffic_route {
        listener_arns = module.ecs.listener_8080_port_arns
      }
    }
  }
}
