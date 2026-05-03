################################################################################
# IAM Module - main.tf
#
# Defines all IAM roles and inline/attached policies required by the Blue-Green
# deployment pipeline and the ECS workload:
#
#   1. ECS EC2 instance role        -> for container-instances in the ASG
#   2. ECS task execution role      -> for the ECS agent to pull images & log
#   3. ECS task role (application)  -> for the running container to call AWS
#   4. CodeBuild role               -> for the build project
#   5. CodeDeploy role              -> for blue/green deployments
#   6. CodePipeline role            -> for pipeline orchestration
#
# Design notes
# ------------
# * Policies are defined as separate aws_iam_role_policy / *_policy_attachment
#   resources (not inline_policy blocks) - the inline_policy argument is
#   deprecated in AWS provider v5+.
# * The CodePipeline role is scoped to the services the pipelines actually use
#   (S3 artifact bucket, CodeBuild, CodeDeploy, CodeStar connections, ECS pass-
#   role, ECR describe, KMS) instead of the previous ec2:* / s3:* / ecs:* /
#   autoscaling:* / elasticloadbalancing:* / cloudwatch:* wildcards.
# * The ECS task role is now distinct from the task execution role so that
#   runtime application permissions (X-Ray, app-specific AWS calls) are
#   separated from image-pull / log-write permissions.
################################################################################


################################################################################
# Locals
################################################################################

locals {
  # Account-and-region-scoped wildcards used in several policies below.
  log_group_arn_any = "arn:aws:logs:${var.region}:${var.account_id}:log-group:*"
  ecr_repo_arn_any  = "arn:aws:ecr:${var.region}:${var.account_id}:repository/*"

  # ARNs of every CodeBuild project the pipeline may invoke.
  codebuild_project_arns = [
    for p in var.codebuild_project_names :
    "arn:aws:codebuild:${var.region}:${var.account_id}:project/${p}-CodeBuild"
  ]
}


################################################################################
# 1. ECS EC2 instance role
#    Attached to EC2 container-instances via an instance profile so the ECS
#    agent can register the node with the cluster and send telemetry.
################################################################################

resource "aws_iam_role" "ecs_instance_role" {
  name = "${var.name}-EcsInstanceRole"
  tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_ecs_managed" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_xray" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}


################################################################################
# 2. ECS Task Execution role
#    Used by the ECS agent on the container-instance to pull the task's image
#    from ECR, fetch secrets, and write container logs to CloudWatch.
#    This role is NOT assumed by the application code.
################################################################################

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name}-EcsTaskExecutionRole"
  tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_managed" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Scoped CloudWatch Logs access for the execution role (replaces the broad
# CloudWatchLogsFullAccess managed policy).
resource "aws_iam_role_policy" "ecs_task_execution_logs" {
  name = "${var.name}-EcsTaskExecutionLogs"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ]
      Resource = local.log_group_arn_any
    }]
  })
}


################################################################################
# 3. ECS Task role (application identity)
#    Assumed by the application container at runtime. Grants the minimum AWS
#    permissions the workload itself needs (currently: X-Ray trace submission).
#    Keep this role small and add only what the app actively calls.
################################################################################

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.name}-EcsTaskRole"
  tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# X-Ray write-only (not the Full Access policy that the old code used).
resource "aws_iam_role_policy_attachment" "ecs_task_xray" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}


################################################################################
# 4. CodeBuild role
#    Used by the CodeBuild projects (dev / main) to: write build logs, read
#    source & write artifacts on S3, publish test reports, push container
#    images to ECR, and use the pipeline KMS key.
################################################################################

resource "aws_iam_role" "codebuild_role" {
  name = "${var.name}-CodebuildRole"
  tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codebuild_inline" {
  name = "${var.name}-CodebuildPolicy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Build-time CloudWatch Logs
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = local.log_group_arn_any
      },
      # Pipeline artifact bucket access
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ]
        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      },
      # CodeBuild report groups (test coverage / reports)
      {
        Effect = "Allow"
        Action = [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
        ]
        Resource = "arn:aws:codebuild:${var.region}:${var.account_id}:report-group/*"
      },
      # ECR push access - token call must remain Resource "*"
      {
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage"
        ]
        Resource = local.ecr_repo_arn_any
      },
      # Artifact encryption with the pipeline's KMS key
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = var.kms_key_arn
      }
    ]
  })
}


################################################################################
# 5. CodeDeploy role
#    Used by CodeDeploy ECS blue/green to swap task sets, move ALB traffic
#    between listeners, and read deployment artifacts.
################################################################################

resource "aws_iam_role" "codedeploy_role" {
  name = "${var.name}-CodedeployRole"
  tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "codedeploy.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codedeploy_inline" {
  name = "${var.name}-CodedeployPolicy"
  role = aws_iam_role.codedeploy_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:CreateTaskSet",
          "ecs:UpdateServicePrimaryTaskSet",
          "ecs:DeleteTaskSet"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:ModifyRule"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["cloudwatch:DescribeAlarms"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "${var.s3_bucket_arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = "*"
        Condition = {
          StringLike = {
            "iam:PassedToService" = ["ecs-tasks.amazonaws.com"]
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ]
        Resource = var.kms_key_arn
      }
    ]
  })
}


################################################################################
# 6. CodePipeline role (scoped)
#    Previously granted ec2:* / s3:* / ecs:* / autoscaling:* /
#    elasticloadbalancing:* / cloudwatch:* / opsworks:* / devicefarm:* /
#    servicecatalog:* / states:* / appconfig:* on Resource "*".
#    Rewritten here to only the actions the Source/Build/Deploy stages
#    actually invoke.
################################################################################

resource "aws_iam_role" "codepipeline_role" {
  name = "${var.name}-CodepipelineRole"
  tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "codepipeline.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codepipeline_inline" {
  name = "${var.name}-CodepipelinePolicy"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # --- Source stage: pull from GitHub via CodeStar Connections ---
      {
        Effect   = "Allow"
        Action   = ["codestar-connections:UseConnection"]
        Resource = "*"
      },

      # --- Build stage: invoke CodeBuild projects ---
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:BatchGetBuildBatches",
          "codebuild:StartBuildBatch"
        ]
        Resource = length(local.codebuild_project_arns) > 0 ? local.codebuild_project_arns : ["*"]
      },

      # --- Deploy stage: trigger CodeDeploy ---
      {
        Effect = "Allow"
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision"
        ]
        Resource = "*"
      },

      # --- Artifact store: read / write the pipeline S3 bucket only ---
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:GetBucketVersioning",
          "s3:GetBucketLocation"
        ]
        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      },

      # --- Artifact encryption ---
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = var.kms_key_arn
      },

      # --- ECR image metadata (read-only, needed for ECS provider deploy actions) ---
      {
        Effect   = "Allow"
        Action   = ["ecr:DescribeImages"]
        Resource = local.ecr_repo_arn_any
      },

      # --- Pass the CodeDeploy service role to the deploy action ---
      {
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = aws_iam_role.codedeploy_role.arn
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "codedeploy.amazonaws.com"
          }
        }
      },

      # --- Pass the ECS task execution role when launching ECS deployments ---
      {
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = aws_iam_role.ecs_task_execution_role.arn
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      }
    ]
  })
}
