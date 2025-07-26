module "security-groups" {
  source = "../security-groups"
  name   = var.name
  vpc_id = var.vpc_id
}
module "alb" {
  source             = "../alb"
  name               = var.name
  security_group_ids = [module.security-groups.alb_security_group_id]
  subnets            = var.public_subnets
  vpc_id             = var.vpc_id
  depends_on = [ module.security-groups ]
}

resource "aws_ecs_cluster" "cluster" {
  name = "${var.name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

data "aws_ssm_parameter" "ecs_node_ami" {
  name = var.asg_ec2_ami_name
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

  depends_on = [aws_ecs_cluster.cluster]
}

resource "aws_ecs_service" "my_ecs_service" {
  name                = "${var.name}-service"
  cluster             = aws_ecs_cluster.cluster.id
  launch_type         = "EC2"
  scheduling_strategy = "REPLICA"
  desired_count       = var.desired_count
  task_definition     = var.task_definition_arn

  load_balancer {
    target_group_arn = module.alb.target_group1_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [module.security-groups.ecs_security_group_id]
    assign_public_ip = false
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }
  depends_on = [module.alb, aws_ecs_cluster.cluster]
}

resource "aws_cloudwatch_metric_alarm" "ecs-alert_High-CPUReservation" {
  alarm_name = "${var.name}-CPU_Utilization_High"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period = "60"
  evaluation_periods = "1"
  datapoints_to_alarm = 1
  statistic = "Average"
  threshold = "60"
  alarm_description = ""
  metric_name = "CPUReservation"
  namespace = "AWS/ECS"
  dimensions = {
    ClusterName = "${aws_ecs_cluster.cluster.name}"
  }
  actions_enabled = true
  insufficient_data_actions = []
  ok_actions = []
  alarm_actions = []
}