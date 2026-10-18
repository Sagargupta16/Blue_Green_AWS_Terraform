# Pipelines: the deploy actions take the digest-pinned build artifact, and
# test and prod read the same one.

mock_provider "aws" {
  source          = "./tests/mocks"
  override_during = plan
}

variables {
  pipeline_role_arn     = "arn:aws:iam::111122223333:role/test-app-CodepipelineRole"
  kms_key_alias         = "alias/test-app-kms-key"
  github_connection_arn = "arn:aws:codeconnections:us-east-1:111122223333:connection/00000000-0000-0000-0000-000000000000"
  github_owner          = "Sagargupta16"
  github_repo           = "Blue_Green_AWS_Terraform"
  artifact_bucket       = "test-app-artifacts"
}

run "main_pipeline_codedeploy_to_ecs" {
  command = plan

  module {
    source = "./codepipeline_main"
  }

  variables {
    name                        = "main-test-app"
    main_branch_name            = "main"
    test_codebuild_project_name = "main-test-app-CodeBuild"
    test_codedeploy_app_name    = "test-test-app-app"
    test_deployment_group_name  = "test-test-app-deploy-grp"
    prod_codedeploy_app_name    = "prod-test-app-app"
    prod_deployment_group_name  = "prod-test-app-deploy-grp"
  }

  assert {
    condition = alltrue([
      for s in aws_codepipeline.main.stage : s.action[0].provider == "CodeDeployToECS"
      if contains(["Deploy-Test", "Deploy-Prod"], s.name)
    ])
    error_message = "Both deploy stages should use CodeDeployToECS, which registers a task definition per build."
  }

  assert {
    condition = alltrue([
      for s in aws_codepipeline.main.stage : s.action[0].input_artifacts == tolist(["build_output_test"])
      if contains(["Deploy-Test", "Deploy-Prod"], s.name)
    ])
    error_message = "Test and prod must deploy the same build artifact."
  }

  assert {
    condition = one([
      for s in aws_codepipeline.main.stage : s.action[0].configuration
      if s.name == "Deploy-Prod"
      ]) == tomap({
      ApplicationName                = "prod-test-app-app"
      DeploymentGroupName            = "prod-test-app-deploy-grp"
      TaskDefinitionTemplateArtifact = "build_output_test"
      TaskDefinitionTemplatePath     = "taskdef.json"
      AppSpecTemplateArtifact        = "build_output_test"
      AppSpecTemplatePath            = "appspec.yml"
      Image1ArtifactName             = "build_output_test"
      Image1ContainerName            = "IMAGE1_NAME"
    })
    error_message = "Prod's CodeDeployToECS config must point at the rendered taskdef.json, appspec.yml and imageDetail.json."
  }

  assert {
    condition     = [for s in aws_codepipeline.main.stage : s.name] == ["Source", "Build", "Deploy-Test", "Manual-Approval", "Deploy-Prod"]
    error_message = "Stage order must keep the manual approval between test and prod."
  }
}

run "main_pipeline_ecs_native" {
  command = plan

  module {
    source = "./codepipeline_main"
  }

  variables {
    name                        = "main-test-app"
    main_branch_name            = "main"
    test_codebuild_project_name = "main-test-app-CodeBuild"
    deployment_engine           = "ecs"
    test_ecs_cluster_name       = "test-test-app-cluster"
    test_ecs_service_name       = "test-test-app-service"
    prod_ecs_cluster_name       = "prod-test-app-cluster"
    prod_ecs_service_name       = "prod-test-app-service"
  }

  assert {
    condition = one([
      for s in aws_codepipeline.main.stage : s.action[0].configuration
      if s.name == "Deploy-Prod"
      ]) == tomap({
      ClusterName = "prod-test-app-cluster"
      ServiceName = "prod-test-app-service"
      FileName    = "imagedefinitions.json"
    })
    error_message = "With the ecs engine, prod deploys through the ECS action and imagedefinitions.json."
  }

  assert {
    condition = alltrue([
      for s in aws_codepipeline.main.stage : s.action[0].provider == "ECS"
      if contains(["Deploy-Test", "Deploy-Prod"], s.name)
    ])
    error_message = "Both deploy stages should use the ECS standard action with the ecs engine."
  }
}

run "dev_pipeline_codedeploy_to_ecs" {
  command = plan

  module {
    source = "./codepipeline_dev"
  }

  variables {
    name                       = "dev-test-app"
    dev_branch_name            = "dev"
    dev_codebuild_project_name = "dev-test-app-CodeBuild"
    dev_codedeploy_app_name    = "dev-test-app-app"
    dev_deployment_group_name  = "dev-test-app-deploy-grp"
  }

  assert {
    condition = one([
      for s in aws_codepipeline.main.stage : s.action[0].configuration["Image1ArtifactName"]
      if s.name == "Deploy-Dev"
    ]) == "build_output_dev"
    error_message = "The dev deploy must read the image from its own build output."
  }
}
