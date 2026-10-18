# Data sources

data "aws_caller_identity" "current" {}


# KMS

resource "aws_kms_key" "kms_key" {
  description              = "KMS key for pipeline artifacts and alarm topics."
  deletion_window_in_days  = 7
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = true

  # Statement 1 is the AWS default key policy (IAM policies decide access).
  # Statement 2 lets CloudWatch publish alarms to the KMS-encrypted SNS topics.
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
      }
    ]
  })
}

resource "aws_kms_alias" "kms_alias" {
  name          = "alias/${var.name}-kms-key"
  target_key_id = aws_kms_key.kms_key.key_id
}
