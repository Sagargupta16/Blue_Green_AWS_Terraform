output "s3_bucket_name" {
  description = "Artifact bucket name."
  value       = aws_s3_bucket.artifact_bucket.bucket
}

output "s3_bucket_arn" {
  description = "Artifact bucket ARN."
  value       = aws_s3_bucket.artifact_bucket.arn
}

# ALB access logs and flow logs check that they can write when they are
# turned on, so anything using these waits for the bucket policy.
output "log_bucket_name" {
  description = "Log bucket name (ALB access logs)."
  value       = aws_s3_bucket.logs.bucket
  depends_on  = [aws_s3_bucket_policy.logs]
}

output "log_bucket_arn" {
  description = "Log bucket ARN (VPC flow logs)."
  value       = aws_s3_bucket.logs.arn
  depends_on  = [aws_s3_bucket_policy.logs]
}
