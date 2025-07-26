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
}

# CodeDeploy App Resource
resource "aws_codedeploy_app" "my_codedeploy_app" {
  name             = "${var.name}-app"
  compute_platform = "ECS"
}

#CodeDeploy Deployment Config Resource
resource "aws_codedeploy_deployment_config" "custom_bluegreen_config" {
  compute_platform       = "ECS"
  deployment_config_name = "${var.name}-bluegreen-config"

  traffic_routing_config {
    type = "TimeBasedCanary"
    time_based_canary {
      interval   = 1
      percentage = 30
    }
  }
}

# CodeDeploy Deployment Group Resource
resource "aws_codedeploy_deployment_group" "example" {
  app_name               = aws_codedeploy_app.my_codedeploy_app.name
  deployment_config_name = aws_codedeploy_deployment_config.custom_bluegreen_config.deployment_config_name
  deployment_group_name  = "${var.name}-deploy-grp"
  service_role_arn       = var.app_task_role_arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0
    }
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 1
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

  depends_on = [ module.ecs, aws_codedeploy_app.my_codedeploy_app, aws_codedeploy_deployment_config.custom_bluegreen_config]
}
