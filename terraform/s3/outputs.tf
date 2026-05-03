################################################################################
# S3 Module - outputs.tf
################################################################################

output "s3_bucket_name" {
  description = "Name of the artifact bucket."
  value       = aws_s3_bucket.artifact_bucket.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the artifact bucket."
  value       = aws_s3_bucket.artifact_bucket.arn
}
