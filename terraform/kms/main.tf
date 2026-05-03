# KMS

resource "aws_kms_key" "kms_key" {
  description              = "KMS key for pipeline artifacts."
  deletion_window_in_days  = 7
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = true
}

resource "aws_kms_alias" "kms_alias" {
  name          = "alias/${var.name}-kms-key"
  target_key_id = aws_kms_key.kms_key.key_id
}
