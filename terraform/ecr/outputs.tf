output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.repo.repository_url
}

output "ecr_repo_arn" {
  description = "The ARN of the ECR repository"
  value       = aws_ecr_repository.repo.arn
}