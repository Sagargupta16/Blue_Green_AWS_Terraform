locals {
  container_name = "${var.name}-container"
}
resource "aws_ecs_task_definition" "task-def" {
  family                   = "${var.name}-task-def"
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_execution_role_arn
  network_mode             = var.task_definition_network_mode
  requires_compatibilities = ["EC2"]
  cpu                      = var.task_definition_cpu
  memory                   = var.task_definition_memory
  container_definitions = jsonencode([
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
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group  = "true"
          awslogs-group         = "${var.name}-LogGroup"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    },
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
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group  = "true"
          awslogs-group         = "${var.name}-LogGroup"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "xray"
        }
      }
    }
  ])
}
