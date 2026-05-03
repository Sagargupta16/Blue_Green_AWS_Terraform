output "ecr_repository_url" {
  description = "ECR repository URL."
  value       = aws_ecr_repository.repo.repository_url
}

output "ecr_repo_arn" {
  description = "ECR repository ARN."
  value       = aws_ecr_repository.repo.arn
}
