# Locals
#
# Both deploy actions read the build artifact, which pins the image by
# digest (imageDetail.json / imagedefinitions.json). Test and prod therefore
# run the exact image that was built and tested, even if a newer build lands
# while this run waits at Manual-Approval.

locals {
  ecs_native = var.deployment_engine == "ecs"

  deploy_provider = local.ecs_native ? "ECS" : "CodeDeployToECS"

  deploy_targets = {
    test = {
      app     = var.test_codedeploy_app_name
      group   = var.test_deployment_group_name
      cluster = var.test_ecs_cluster_name
      service = var.test_ecs_service_name
    }
    prod = {
      app     = var.prod_codedeploy_app_name
      group   = var.prod_deployment_group_name
      cluster = var.prod_ecs_cluster_name
      service = var.prod_ecs_service_name
    }
  }

  deploy_config = {
    for env, target in local.deploy_targets :
    env => local.ecs_native ? tomap({
      ClusterName = target.cluster
      ServiceName = target.service
      FileName    = "imagedefinitions.json"
      }) : tomap({
      ApplicationName                = target.app
      DeploymentGroupName            = target.group
      TaskDefinitionTemplateArtifact = "build_output_test"
      TaskDefinitionTemplatePath     = "taskdef.json"
      AppSpecTemplateArtifact        = "build_output_test"
      AppSpecTemplatePath            = "appspec.yml"
      Image1ArtifactName             = "build_output_test"
      Image1ContainerName            = "IMAGE1_NAME"
    })
  }
}


# Data sources

data "aws_kms_alias" "kmskey" {
  name = var.kms_key_alias
}


# Pipeline (Source -> Build -> Deploy-Test -> Approval -> Deploy-Prod)

resource "aws_codepipeline" "main" {
  name          = "${var.name}-Codepipeline"
  pipeline_type = "V2"
  role_arn      = var.pipeline_role_arn

  artifact_store {
    type     = "S3"
    location = var.artifact_bucket

    encryption_key {
      id   = data.aws_kms_alias.kmskey.arn
      type = "KMS"
    }
  }

  trigger {
    provider_type = "CodeStarSourceConnection"

    git_configuration {
      source_action_name = "Source"
      push {
        branches {
          includes = [var.main_branch_name]
        }
      }
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output_test"]

      configuration = {
        ConnectionArn    = var.github_connection_arn
        FullRepositoryId = "${var.github_owner}/${var.github_repo}"
        BranchName       = var.main_branch_name
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output_test"]
      output_artifacts = ["build_output_test"]

      configuration = {
        ProjectName = var.test_codebuild_project_name
      }
    }
  }

  stage {
    name = "Deploy-Test"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = local.deploy_provider
      version         = "1"
      input_artifacts = ["build_output_test"]
      configuration   = local.deploy_config["test"]
    }
  }

  stage {
    name = "Manual-Approval"

    action {
      name      = "Manual-Approval"
      category  = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
      run_order = 1
    }
  }

  stage {
    name = "Deploy-Prod"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = local.deploy_provider
      version         = "1"
      input_artifacts = ["build_output_test"]
      configuration   = local.deploy_config["prod"]
    }
  }
}
