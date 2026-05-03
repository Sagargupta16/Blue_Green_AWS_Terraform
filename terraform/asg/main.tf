################################################################################
# ASG Module - main.tf
#
# Builds the EC2 capacity for an ECS cluster:
#
#   1. IAM instance profile  -> wraps the ECS instance role created by the IAM
#                               module so the EC2 instances can register with
#                               the cluster
#   2. Launch template       -> ECS-optimized AMI, IMDSv2 enforced, user-data
#                               joins the cluster on boot
#   3. Auto Scaling Group    -> spans the private subnets, lives only in the
#                               private tier
#   4. ECS capacity provider -> managed-scaling at 100% target capacity, wired
#                               into the cluster as the default provider
################################################################################


################################################################################
# Instance profile
################################################################################

resource "aws_iam_instance_profile" "ecs_node" {
  name = "${var.name}-node-profile"
  role = var.ecs_instance_role_name
}


################################################################################
# Launch template
################################################################################

resource "aws_launch_template" "ecs_ec2" {
  name                   = "${var.name}-launch-template"
  image_id               = var.asg_ec2_image_id
  instance_type          = var.asg_ec2_instance_type
  vpc_security_group_ids = var.security_group_ids

  # Enforce IMDSv2 (session tokens) and restrict PUT-response hop limit to 1.
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

  # Boot-time ECS cluster join + patch.
  user_data = base64encode(<<EOF
    #!/bin/bash
    echo ECS_CLUSTER=${var.ecs_cluster_name} >> /etc/ecs/ecs.config;
    sudo yum update -y
  EOF
  )
}


################################################################################
# Auto Scaling Group
################################################################################

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

  # Required so the ECS capacity provider can manage the ASG.
  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
}


################################################################################
# ECS capacity provider
################################################################################

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

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = var.ecs_cluster_name
  capacity_providers = [aws_ecs_capacity_provider.main.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    base              = 1
    weight            = 100
  }
}
