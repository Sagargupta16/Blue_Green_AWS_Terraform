# Load balancer

resource "aws_lb" "alb" {
  name                       = "${var.name}-ALB"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = var.security_group_ids
  subnets                    = var.subnets
  enable_deletion_protection = true
  idle_timeout               = 60
  drop_invalid_header_fields = true
}


# Target groups (blue/green)

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


# Listeners

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

  # CodeDeploy swaps the default action to the green target group on every
  # deployment. Without this, the next `terraform apply` points traffic back
  # at target group 1, which may hold no tasks after a successful deploy.
  lifecycle {
    ignore_changes = [default_action]
  }
}

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

  lifecycle {
    ignore_changes = [default_action]
  }
}


# Listener rules (ECS native blue/green only)
#
# ECS native deployments shift traffic by rewriting the weights on a listener
# rule, not on the listener itself. Both target groups sit in the forward
# action; ECS moves the weight from one to the other.

resource "aws_lb_listener_rule" "production" {
  count = var.create_listener_rules ? 1 : 0

  listener_arn = aws_lb_listener.http.arn
  priority     = 1

  action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.target_group1.arn
        weight = 100
      }
      target_group {
        arn    = aws_lb_target_group.target_group2.arn
        weight = 0
      }
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  lifecycle {
    ignore_changes = [action]
  }
}

resource "aws_lb_listener_rule" "test" {
  count = var.create_listener_rules ? 1 : 0

  listener_arn = aws_lb_listener.http_8080.arn
  priority     = 1

  action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.target_group1.arn
        weight = 100
      }
      target_group {
        arn    = aws_lb_target_group.target_group2.arn
        weight = 0
      }
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  lifecycle {
    ignore_changes = [action]
  }
}
