################################################################################
# CodePipeline (Dev) Module - main.tf
#
# Two-stage CI/CD pipeline for the development environment:
#
#   Source (GitHub via CodeStar Connection, push trigger on dev_branch_name)
#     -> Build-Dev (CodeBuild)
#     -> Deploy-Dev (CodeDeploy blue/green)
#
# Pipeline-type V2 is used so the `trigger` block (webhook filter on push
# events for a specific branch) is supported.
################################################################################


################################################################################
# Data sources
################################################################################

data "aws_kms_alias" "kmskey" {
  name = var.kms_key_alias
}


################################################################################
# Pipeline
################################################################################

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

  # V2 webhook trigger: fire on pushes to the dev branch.
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

  # ---- Stage 1: Source (GitHub) --------------------------------------------
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

  # ---- Stage 2: Build (CodeBuild) ------------------------------------------
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

  # ---- Stage 3: Deploy (CodeDeploy blue/green) -----------------------------
  stage {
    name = "Deploy-Dev"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      version         = "1"
      input_artifacts = ["build_output_dev"]

      configuration = {
        ApplicationName     = var.dev_codedeploy_app_name
        DeploymentGroupName = var.dev_deployment_group_name
      }
    }
  }
}
