# ALB resource with access logging enabled
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

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.target_group2.arn
      }
    }
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
}
