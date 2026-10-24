# Locals

locals {
  container_name = "${var.name}-container"
  log_group      = "${var.name}-LogGroup"
}


# Task definition

resource "aws_ecs_task_definition" "task_def" {
  family                   = "${var.name}-task-def"
  network_mode             = var.task_definition_network_mode
  requires_compatibilities = ["EC2"]
  cpu                      = var.task_definition_cpu
  memory                   = var.task_definition_memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  # Both containers run with a read-only root filesystem: the app only reads
  # client/build and logs to stdout, and the X-Ray daemon only logs to stdout.
  container_definitions = jsonencode([
    {
      name                   = local.container_name
      image                  = var.task_definition_image
      cpu                    = 0
      essential              = true
      readonlyRootFilesystem = true
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
    {
      name                   = "xray-daemon"
      image                  = "public.ecr.aws/xray/aws-xray-daemon:latest"
      cpu                    = 0
      essential              = false
      readonlyRootFilesystem = true
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
