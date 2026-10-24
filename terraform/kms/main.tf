# Data sources

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


# KMS

resource "aws_kms_key" "kms_key" {
  description              = "KMS key for pipeline artifacts and alarm topics."
  deletion_window_in_days  = 7
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = true

  # Statement 1 is the AWS default key policy (IAM policies decide access).
  # Statement 2 lets CloudWatch publish alarms to the KMS-encrypted SNS topics.
  # Statement 3 lets CloudWatch Logs encrypt the VPC flow log group, and only
  # that group (the vpc module names it <name>-vpc-flow-logs).
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AccountRootFullAccess"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "CloudWatchAlarmsToSns"
        Effect    = "Allow"
        Principal = { Service = "cloudwatch.amazonaws.com" }
        Action    = ["kms:Decrypt", "kms:GenerateDataKey*"]
        Resource  = "*"
      },
      {
        Sid       = "CloudWatchLogsFlowLogGroup"
        Effect    = "Allow"
        Principal = { Service = "logs.${data.aws_region.current.region}.amazonaws.com" }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = "*"
        Condition = {
          ArnEquals = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:${var.name}-vpc-flow-logs"
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "kms_alias" {
  name          = "alias/${var.name}-kms-key"
  target_key_id = aws_kms_key.kms_key.key_id
}
