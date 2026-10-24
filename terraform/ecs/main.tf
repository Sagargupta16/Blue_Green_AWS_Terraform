# Locals

locals {
  ecs_native = var.deployment_engine == "ecs"

  rollback_alarm_names = [
    aws_cloudwatch_metric_alarm.target_5xx.alarm_name,
    aws_cloudwatch_metric_alarm.unhealthy_hosts.alarm_name,
  ]
}


# Data sources

data "aws_ssm_parameter" "ecs_node_ami" {
  name = var.asg_ec2_ami_name
}


# Nested modules

module "security-groups" {
  source = "../security-groups"
  name   = var.name
  vpc_id = var.vpc_id
}

module "alb" {
  source                = "../alb"
  name                  = var.name
  security_group_ids    = [module.security-groups.alb_security_group_id]
  subnets               = var.public_subnets
  vpc_id                = var.vpc_id
  create_listener_rules = local.ecs_native
  access_logs_bucket    = var.log_bucket_name
}

module "asg" {
  source                 = "../asg"
  name                   = var.name
  asg_ec2_image_id       = data.aws_ssm_parameter.ecs_node_ami.value
  asg_ec2_instance_type  = var.asg_ec2_instance_type
  security_group_ids     = [module.security-groups.ecs_security_group_id]
  asg_desired_capacity   = var.asg_desired_capacity
  asg_max_size           = var.asg_max_size
  asg_min_size           = var.asg_min_size
  private_subnets        = var.private_subnets
  ecs_cluster_name       = aws_ecs_cluster.cluster.name
  ecs_instance_role_name = var.ecs_instance_role_name
}


# ECS cluster

resource "aws_ecs_cluster" "cluster" {
  name = "${var.name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


# ECS service
#
# deployment_engine = "codedeploy": CODE_DEPLOY controller, CodeDeploy owns
#   the task sets and the listener swap.
# deployment_engine = "ecs": ECS controller with the built-in BLUE_GREEN or
#   CANARY strategy (GA 2025-07). ECS rewrites the listener-rule weights
#   itself and rolls back on the circuit breaker or the alarms below.

resource "aws_ecs_service" "my_ecs_service" {
  name                               = "${var.name}-service"
  cluster                            = aws_ecs_cluster.cluster.id
  launch_type                        = "EC2"
  scheduling_strategy                = "REPLICA"
  desired_count                      = var.desired_count
  task_definition                    = var.task_definition_arn
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  load_balancer {
    target_group_arn = module.alb.target_group1_arn
    container_name   = var.container_name
    container_port   = var.container_port

    dynamic "advanced_configuration" {
      for_each = local.ecs_native ? [1] : []
      content {
        alternate_target_group_arn = module.alb.target_group2_arn
        production_listener_rule   = module.alb.production_listener_rule_arn
        test_listener_rule         = module.alb.test_listener_rule_arn
        role_arn                   = var.ecs_infrastructure_role_arn
      }
    }
  }

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [module.security-groups.ecs_security_group_id]
    assign_public_ip = false
  }

  deployment_controller {
    type = local.ecs_native ? "ECS" : "CODE_DEPLOY"
  }

  dynamic "deployment_configuration" {
    for_each = local.ecs_native ? [1] : []
    content {
      strategy             = var.ecs_deployment_strategy
      bake_time_in_minutes = var.bake_time_minutes

      dynamic "canary_configuration" {
        for_each = var.ecs_deployment_strategy == "CANARY" ? [1] : []
        content {
          canary_percent              = var.canary_percent
          canary_bake_time_in_minutes = var.canary_interval_minutes
        }
      }
    }
  }

  # The circuit breaker and alarm rollback only exist for the ECS controller;
  # with CODE_DEPLOY the same alarms sit on the deployment group instead.
  dynamic "deployment_circuit_breaker" {
    for_each = local.ecs_native ? [1] : []
    content {
      enable   = true
      rollback = true
    }
  }

  dynamic "alarms" {
    for_each = local.ecs_native ? [1] : []
    content {
      alarm_names = local.rollback_alarm_names
      enable      = true
      rollback    = true
    }
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count,
      load_balancer
    ]
  }
}


# Monitoring

resource "aws_cloudwatch_metric_alarm" "ecs-alert_High-CPUReservation" {
  alarm_name          = "${var.name}-CPU_Utilization_High"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = "60"
  evaluation_periods  = "1"
  datapoints_to_alarm = 1
  statistic           = "Average"
  threshold           = "60"
  alarm_description   = "ECS cluster CPUReservation >= 60% over 1 minute."
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"

  dimensions = {
    ClusterName = aws_ecs_cluster.cluster.name
  }

  actions_enabled           = true
  insufficient_data_actions = []
  ok_actions                = []
  alarm_actions             = [aws_sns_topic.alarms.arn]
}


# Rollback alarms
#
# Both engines watch these during a deployment: CodeDeploy through the
# deployment group's alarm_configuration, ECS native through the service's
# alarms block. Either one going to ALARM rolls traffic back to blue.

resource "aws_cloudwatch_metric_alarm" "target_5xx" {
  alarm_name          = "${var.name}-Target-5XX"
  alarm_description   = "Targets behind the ALB returned >= ${var.rollback_5xx_threshold} HTTP 5xx in 1 minute. Rolls back an in-flight deployment."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  period              = 60
  statistic           = "Sum"
  threshold           = var.rollback_5xx_threshold
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = module.alb.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  alarm_name          = "${var.name}-Unhealthy-Hosts"
  alarm_description   = "A blue or green target group had an unhealthy target for 2 consecutive minutes. Rolls back an in-flight deployment."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  threshold           = 1
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "worst"
    expression  = "MAX([blue, green])"
    label       = "Unhealthy targets (worst of blue and green)"
    return_data = true
  }

  dynamic "metric_query" {
    for_each = {
      blue  = module.alb.target_group_arn_suffixes[0]
      green = module.alb.target_group_arn_suffixes[1]
    }
    content {
      id = metric_query.key
      metric {
        metric_name = "UnHealthyHostCount"
        namespace   = "AWS/ApplicationELB"
        period      = 60
        stat        = "Maximum"
        dimensions = {
          LoadBalancer = module.alb.alb_arn_suffix
          TargetGroup  = metric_query.value
        }
      }
    }
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
}


# Alarm notifications (encrypted with the project CMK, whose key policy lets
# CloudWatch publish)

resource "aws_sns_topic" "alarms" {
  name              = "${var.name}-alarms"
  kms_master_key_id = var.kms_key_arn
}

resource "aws_sns_topic_subscription" "alarm_email" {
  count = var.alarm_email == "" ? 0 : 1

  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}
