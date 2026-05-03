################################################################################
# KMS Module - main.tf
#
# Creates the single customer-managed KMS key used to encrypt artifacts across
# the pipeline (S3 artifact bucket, ECR images, CodeBuild artifacts,
# CodePipeline artifacts, CodeDeploy downloads).
#
# Key rotation is enabled and the key has a 7-day deletion window so an
# accidental destroy can be recovered.
################################################################################

resource "aws_kms_key" "kms_key" {
  description              = "KMS key for encrypting and decrypting pipeline artifacts."
  deletion_window_in_days  = 7
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = true

  tags = {
    Name = "${var.name}-kms-key"
  }
}

resource "aws_kms_alias" "kms_alias" {
  name          = "alias/${var.name}-kms-key"
  target_key_id = aws_kms_key.kms_key.key_id
}
