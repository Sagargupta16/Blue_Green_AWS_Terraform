################################################################################
# KMS Module - outputs.tf
################################################################################

output "kms_key_alias" {
  description = "Alias of the KMS key (e.g. alias/<name>-kms-key)."
  value       = aws_kms_alias.kms_alias.name
}

output "kms_key_arn" {
  description = "ARN of the KMS key."
  value       = aws_kms_key.kms_key.arn
}
