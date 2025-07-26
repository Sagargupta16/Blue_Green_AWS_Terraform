# --- ECS-EC2 Launch Template ---
resource "aws_iam_instance_profile" "ecs_node" {
  name = "${var.name}-node-profile"
  role = var.ecs_instance_role_name
}

resource "aws_launch_template" "ecs_ec2" {
  name                   = "${var.name}-launch-template"
  image_id               = var.asg_ec2_image_id
  instance_type          = var.asg_ec2_instance_type
  vpc_security_group_ids = var.security_group_ids
  metadata_options {
    http_tokens                 = "required"
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.ecs_node.arn
  }

  monitoring {
    enabled = true
  }

  user_data = base64encode(<<EOF
    #!/bin/bash
    echo ECS_CLUSTER=${var.ecs_cluster_name} >> /etc/ecs/ecs.config;
    sudo yum update -y
  EOF
  )
}

# --- ECS ASG ---
resource "aws_autoscaling_group" "ecs" {
  name = "${var.name}-ASG"

  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_desired_capacity
  health_check_grace_period = 60
  health_check_type         = "EC2"
  protect_from_scale_in     = false
  vpc_zone_identifier       = var.private_subnets

  launch_template {
    id      = aws_launch_template.ecs_ec2.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
}

# --- ECS Capacity Provider ---
resource "aws_ecs_capacity_provider" "main" {
  name = "${var.name}-capacity_provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

# --- ECS Cluster Capacity Providers ---
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = var.ecs_cluster_name
  capacity_providers = [aws_ecs_capacity_provider.main.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    base              = 1
    weight            = 100
  }
}