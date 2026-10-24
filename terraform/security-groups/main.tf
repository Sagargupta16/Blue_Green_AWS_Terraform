# Security groups

resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "ALB security group."
  vpc_id      = var.vpc_id
}

resource "aws_security_group" "ecs" {
  name        = "${var.name}-ecs-sg"
  description = "ECS task and container-instance security group."
  vpc_id      = var.vpc_id
}


# ALB rules

resource "aws_security_group_rule" "alb_ingress_port_80" {
  type              = "ingress"
  description       = "Production listener (HTTP 80) from the internet"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_ingress_port_8080" {
  type              = "ingress"
  description       = "Blue/green test listener (HTTP 8080) from the internet"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_egress" {
  type                     = "egress"
  description              = "Forwarded requests and health checks to the ECS tasks"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.ecs.id
  security_group_id        = aws_security_group.alb.id
}


# ECS rules

resource "aws_security_group_rule" "ecs_ingress" {
  type                     = "ingress"
  description              = "Requests and health checks from the ALB"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ecs.id
}

# Everything the tasks and container-instances call is HTTPS through the NAT
# gateways: ECR and ECR Public, the ECS agent endpoints, CloudWatch Logs, X-Ray,
# SSM and the dnf repositories. Security groups do not filter Amazon DNS,
# instance and task metadata or the Time Sync Service, so those keep working.
resource "aws_security_group_rule" "ecs_egress" {
  type              = "egress"
  description       = "HTTPS out through the NAT gateways (ECR, ECS, CloudWatch Logs, X-Ray, SSM, dnf)"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs.id
}
