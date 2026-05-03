################################################################################
# Security Groups Module - main.tf
#
# Two-tier security group pattern used by the ECS+ALB stack:
#
#   alb-sg      (ingress: 80/8080 from the internet, egress: -> ecs-sg)
#      |
#      v
#   ecs-sg      (ingress: all from alb-sg, egress: 0.0.0.0/0 for NAT egress)
#
# Ports:
#   * 80   - production traffic
#   * 8080 - test (green) traffic route used during blue/green verification
################################################################################


################################################################################
# Security groups
################################################################################

resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "Security group for the environment's Application Load Balancer."
  vpc_id      = var.vpc_id
}

resource "aws_security_group" "ecs" {
  name        = "${var.name}-ecs-sg"
  description = "Security group for ECS tasks and container-instances."
  vpc_id      = var.vpc_id
}


################################################################################
# ALB rules
################################################################################

# ALB ingress: port 80 (prod) and 8080 (test) from anywhere.
resource "aws_security_group_rule" "alb_ingress_port_80" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_ingress_port_8080" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

# ALB egress: only to the ECS security group.
resource "aws_security_group_rule" "alb_egress" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.ecs.id
  security_group_id        = aws_security_group.alb.id
}


################################################################################
# ECS rules
################################################################################

# ECS ingress: all ports from the ALB security group only.
resource "aws_security_group_rule" "ecs_ingress" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ecs.id
}

# ECS egress: any destination (needed for NAT-based outbound to the internet,
# ECR, CloudWatch, X-Ray, etc.).
resource "aws_security_group_rule" "ecs_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs.id
}
