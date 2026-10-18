# Locals

locals {
  ecs_native = var.deployment_engine == "ecs"

  deploy_config = local.ecs_native ? tomap({
    ClusterName = var.dev_ecs_cluster_name
    ServiceName = var.dev_ecs_service_name
    FileName    = "imagedefinitions.json"
    }) : tomap({
    ApplicationName                = var.dev_codedeploy_app_name
    DeploymentGroupName            = var.dev_deployment_group_name
    TaskDefinitionTemplateArtifact = "build_output_dev"
    TaskDefinitionTemplatePath     = "taskdef.json"
    AppSpecTemplateArtifact        = "build_output_dev"
    AppSpecTemplatePath            = "appspec.yml"
    Image1ArtifactName             = "build_output_dev"
    Image1ContainerName            = "IMAGE1_NAME"
  })
}


# Data sources

data "aws_kms_alias" "kmskey" {
  name = var.kms_key_alias
}


# Pipeline (Source -> Build -> Deploy-Dev)

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
          includes = [var.dev_branch_name]
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
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.github_connection_arn
        FullRepositoryId = "${var.github_owner}/${var.github_repo}"
        BranchName       = var.dev_branch_name
      }
    }
  }

  stage {
    name = "Build-Dev"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output_dev"]

      configuration = {
        ProjectName = var.dev_codebuild_project_name
      }
    }
  }

  stage {
    name = "Deploy-Dev"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = local.ecs_native ? "ECS" : "CodeDeployToECS"
      version         = "1"
      input_artifacts = ["build_output_dev"]
      configuration   = local.deploy_config
    }
  }
}
