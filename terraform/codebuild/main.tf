data "aws_kms_alias" "kmskey" {
  name = var.aws_kms_alias
}

resource "aws_codebuild_project" "build" {
  name         = "${var.name}-CodeBuild"
  service_role = var.codebuild_role_arn

  encryption_key = data.aws_kms_alias.kmskey.arn

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_MEDIUM"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "ecr_repository_url"
      value = var.ecr_repository_url
    }

    environment_variable {
      name  = "task_definition_arn"
      value = var.task_definition_arn
    }

    environment_variable {
      name  = "container_name"
      value = var.container_name
    }

    environment_variable {
      name  = "container_port"
      value = var.container_port
    }

    environment_variable {
      name  = "build_env"
      value = var.build_env
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/${var.name}-CodeBuild"
      stream_name = "build"
    }
  }
}
