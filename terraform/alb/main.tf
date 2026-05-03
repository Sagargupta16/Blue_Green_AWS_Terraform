################################################################################
# ALB Module - main.tf
#
# Creates one internet-facing Application Load Balancer per environment along
# with the two target groups and two listeners that CodeDeploy ECS blue/green
# deployments swap between:
#
#                         listener :80    (prod traffic)
#                         listener :8080  (test/green traffic)
#                                \      /
#                                 \    /
#                     target_group1    target_group2
#                       (blue)             (green)
#
# During a blue/green deployment CodeDeploy registers the new task set on the
# idle target group, sends test traffic through :8080 to verify it, then flips
# :80 to point at the new target group.
################################################################################


################################################################################
# Load balancer
################################################################################

resource "aws_lb" "alb" {
  name               = "${var.name}-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnets

  enable_deletion_protection = true
  idle_timeout               = 60
  drop_invalid_header_fields = true
}


################################################################################
# Target groups (blue / green pair)
################################################################################

resource "aws_lb_target_group" "target_group1" {
  name        = "${var.name}-ALB-TG-1"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "target_group2" {
  name        = "${var.name}-ALB-TG-2"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}


################################################################################
# Listeners
################################################################################

# Production listener - routed to target_group1 by default. CodeDeploy flips
# this to target_group2 at the end of a successful blue/green deployment.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.target_group1.arn
      }
    }
  }
}

# Test/green listener - used during a deployment to verify the incoming task
# set before production traffic is shifted.
resource "aws_lb_listener" "http_8080" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.target_group1.arn
      }
    }
  }
}
