output "s3_bucket_name" {
  description = "The name of the s3 bucket"
  value       = aws_s3_bucket.artifact_bucket.bucket
}

output "s3_bucket_arn" {
  description = "The ARN of the s3 bucket"
  value       = aws_s3_bucket.artifact_bucket.arn
}