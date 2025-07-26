output "kms_key_alias" {
  description = "KMS key alias"
  value       = aws_kms_alias.kms_alias.name
}

output "kms_key_arn" {
  description = "KMS key ARN"
  value = aws_kms_key.kms_key.arn
}