# ALB: weighted listener rules exist only for ECS native blue/green.

mock_provider "aws" {
  source          = "./tests/mocks"
  override_during = plan
}

variables {
  name               = "test-app"
  vpc_id             = "vpc-0123456789abcdef0"
  subnets            = ["subnet-0000000000000000a", "subnet-0000000000000000b"]
  security_group_ids = ["sg-0123456789abcdef0"]
  access_logs_bucket = "test-app-logs"
}

run "no_rules_for_codedeploy" {
  command = plan

  module {
    source = "./alb"
  }

  assert {
    condition     = length(aws_lb_listener_rule.production) == 0 && length(aws_lb_listener_rule.test) == 0
    error_message = "CodeDeploy swaps the listeners; rules would fight it."
  }
}

run "weighted_rules_for_ecs_native" {
  command = plan

  module {
    source = "./alb"
  }

  variables {
    create_listener_rules = true
  }

  assert {
    condition = alltrue([
      for rule in [aws_lb_listener_rule.production[0], aws_lb_listener_rule.test[0]] :
      length(rule.action[0].forward[0].target_group) == 2
    ])
    error_message = "Both rules must forward to blue and green so ECS can move the weights."
  }

  assert {
    condition     = sum([for tg in aws_lb_listener_rule.production[0].action[0].forward[0].target_group : tg.weight]) == 100
    error_message = "Production weights must add up to 100 before the first deployment."
  }
}
