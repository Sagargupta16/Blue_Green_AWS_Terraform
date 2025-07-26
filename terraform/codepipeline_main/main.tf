data "aws_kms_alias" "kmskey" {
  name = var.kms_key_alias
}

resource "aws_codepipeline" "main" {
  name     = "${var.name}-Codepipeline"
  pipeline_type = "V2"
  role_arn = var.pipeline_role_arn

  artifact_store {
    type     = "S3"
    location = var.artifact_bucket

    encryption_key {
      id   = data.aws_kms_alias.kmskey.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output_test"]

      configuration = {
        RepositoryName = var.codecommit_repository_name
        BranchName     = var.main_branch_name

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
      provider        = "CodeDeploy"
      version         = "1"
      input_artifacts = ["build_output_test"]

      configuration = {
        ApplicationName     = var.test_codedeploy_app_name
        DeploymentGroupName = var.test_deployment_group_name
      }
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