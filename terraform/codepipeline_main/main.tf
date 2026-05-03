################################################################################
# CodePipeline (Main) Module - main.tf
#
# Five-stage CI/CD pipeline for the production track:
#
#   Source (GitHub, push trigger on main_branch_name)
#     -> Build (CodeBuild)                       [build once]
#     -> Deploy-Test    (CodeDeploy blue/green)
#     -> Manual-Approval
#     -> Deploy-Prod    (CodeDeploy blue/green)  [reuses the test artifact]
#
# "Build once, promote the same artifact" is enforced by reusing the
# `build_output_test` artifact across both Deploy stages, so prod runs the
# exact image that passed test.
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

  # V2 webhook trigger: fire on pushes to the main/production branch.
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

  # ---- Stage 1: Source ------------------------------------------------------
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

  # ---- Stage 2: Build -------------------------------------------------------
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

  # ---- Stage 3: Deploy-Test -------------------------------------------------
  stage {
    name = "Deploy-Test"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      version         = "1"
      input_artifacts = ["build_output_test"]

      configuration = {
        ApplicationName     = var.test_codedeploy_app_name
        DeploymentGroupName = var.test_deployment_group_name
      }
    }
  }

  # ---- Stage 4: Manual approval gate ---------------------------------------
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

  # ---- Stage 5: Deploy-Prod (same artifact promoted) -----------------------
  stage {
    name = "Deploy-Prod"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      version         = "1"
      input_artifacts = ["build_output_test"]

      configuration = {
        ApplicationName     = var.prod_codedeploy_app_name
        DeploymentGroupName = var.prod_deployment_group_name
      }
    }
  }
}
