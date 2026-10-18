# IAM: each engine gets the permissions its deploy action needs, and no more.

mock_provider "aws" {
  source          = "./tests/mocks"
  override_during = plan
}

variables {
  name                    = "test-app"
  region                  = "us-east-1"
  account_id              = "111122223333"
  s3_bucket_arn           = "arn:aws:s3:::test-app-artifacts"
  kms_key_arn             = "arn:aws:kms:us-east-1:111122223333:key/00000000-0000-0000-0000-000000000000"
  codebuild_project_names = ["dev-test-app", "main-test-app"]
  github_connection_arn   = "arn:aws:codeconnections:us-east-1:111122223333:connection/00000000-0000-0000-0000-000000000000"
}

override_resource {
  target          = aws_iam_role.ecs_task_role
  override_during = plan
  values = {
    arn = "arn:aws:iam::111122223333:role/test-app-EcsTaskRole"
  }
}

override_resource {
  target          = aws_iam_role.ecs_task_execution_role
  override_during = plan
  values = {
    arn = "arn:aws:iam::111122223333:role/test-app-EcsTaskExecutionRole"
  }
}

run "codedeploy_engine_permissions" {
  command = plan

  module {
    source = "./iam"
  }

  assert {
    condition = anytrue([
      for st in jsondecode(aws_iam_role_policy.codepipeline_inline.policy).Statement :
      st.Action == ["iam:PassRole"] && try(toset(st.Resource), toset([st.Resource])) == toset([
        "arn:aws:iam::111122223333:role/test-app-EcsTaskExecutionRole",
        "arn:aws:iam::111122223333:role/test-app-EcsTaskRole",
      ])
    ])
    error_message = "Registering a task definition per build passes both the execution role and the task role."
  }

  assert {
    condition = anytrue([
      for st in jsondecode(aws_iam_role_policy.codepipeline_inline.policy).Statement :
      contains(st.Action, "ecs:RegisterTaskDefinition")
    ])
    error_message = "CodeDeployToECS registers a task-definition revision per build."
  }

  assert {
    condition = !anytrue([
      for st in jsondecode(aws_iam_role_policy.codepipeline_inline.policy).Statement :
      contains(st.Action, "ecs:UpdateService")
    ])
    error_message = "With CodeDeploy the pipeline must not be able to update services directly."
  }

  assert {
    condition = anytrue([
      for st in jsondecode(aws_iam_role_policy.codepipeline_inline.policy).Statement :
      contains(st.Action, "codeconnections:UseConnection") && st.Resource == var.github_connection_arn
    ])
    error_message = "UseConnection should be scoped to the one GitHub connection."
  }

  assert {
    condition = anytrue([
      for st in jsondecode(aws_iam_role_policy.codebuild_inline.policy).Statement :
      contains(st.Action, "ecs:DescribeTaskDefinition")
    ])
    error_message = "CodeBuild reads the task definition to render taskdef.json."
  }

  assert {
    condition     = length(aws_iam_role.ecs_infrastructure_role) == 0
    error_message = "The ECS infrastructure role is only for the ecs engine."
  }
}

run "ecs_engine_permissions" {
  command = plan

  module {
    source = "./iam"
  }

  variables {
    deployment_engine = "ecs"
  }

  assert {
    condition = anytrue([
      for st in jsondecode(aws_iam_role_policy.codepipeline_inline.policy).Statement :
      contains(st.Action, "ecs:UpdateService") && st.Resource == "arn:aws:ecs:us-east-1:111122223333:service/*-test-app-cluster/*"
    ])
    error_message = "The ECS deploy action needs UpdateService, scoped to this project's clusters."
  }

  assert {
    condition     = jsondecode(aws_iam_role.ecs_infrastructure_role[0].assume_role_policy).Statement[0].Principal.Service == "ecs.amazonaws.com"
    error_message = "ECS itself assumes the infrastructure role."
  }

  assert {
    condition     = aws_iam_role_policy_attachment.ecs_infrastructure_lb[0].policy_arn == "arn:aws:iam::aws:policy/AmazonECSInfrastructureRolePolicyForLoadBalancers"
    error_message = "The infrastructure role needs the AWS managed load-balancer policy."
  }
}
