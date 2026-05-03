################################################################################
# Task Definition Module - main.tf
#
# Registers an ECS task definition with two containers:
#   1. The application container (port var.container_port)
#   2. An AWS X-Ray daemon sidecar (UDP 2000) used for distributed tracing
#
# The task uses two DIFFERENT IAM identities:
#   * execution_role_arn -> used by the ECS agent to pull the image from ECR
#                           and stream container logs to CloudWatch Logs
#   * task_role_arn      -> used by the application itself to call AWS APIs
#                           (X-Ray, etc.) at runtime
################################################################################


################################################################################
# Locals
################################################################################

locals {
  container_name = "${var.name}-container"
  log_group      = "${var.name}-LogGroup"
}


################################################################################
# Resources
################################################################################

resource "aws_ecs_task_definition" "task_def" {
  family                   = "${var.name}-task-def"
  network_mode             = var.task_definition_network_mode
  requires_compatibilities = ["EC2"]
  cpu                      = var.task_definition_cpu
  memory                   = var.task_definition_memory

  # Distinct roles:
  execution_role_arn = var.ecs_task_execution_role_arn
  task_role_arn      = var.ecs_task_role_arn

  tags = var.tags

  container_definitions = jsonencode([
    # --- Application container ------------------------------------------------
    {
      name      = local.container_name
      image     = var.task_definition_image
      cpu       = 0
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group  = "true"
          awslogs-group         = local.log_group
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    },

    # --- X-Ray daemon sidecar -------------------------------------------------
    {
      name      = "xray-daemon"
      image     = "amazon/aws-xray-daemon"
      cpu       = 0
      essential = false
      portMappings = [
        {
          containerPort = 2000
          protocol      = "udp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group  = "true"
          awslogs-group         = local.log_group
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "xray"
        }
      }
    }
  ])
}
