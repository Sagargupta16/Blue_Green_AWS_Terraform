output "s3_bucket_name" {
  description = "Artifact bucket name."
  value       = aws_s3_bucket.artifact_bucket.bucket
}

output "s3_bucket_arn" {
  description = "Artifact bucket ARN."
  value       = aws_s3_bucket.artifact_bucket.arn
}
