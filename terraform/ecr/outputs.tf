################################################################################
# ECR Module - outputs.tf
################################################################################

output "ecr_repository_url" {
  description = "URL of the ECR repository (used as the image registry in task definitions and CodeBuild)."
  value       = aws_ecr_repository.repo.repository_url
}

output "ecr_repo_arn" {
  description = "ARN of the ECR repository."
  value       = aws_ecr_repository.repo.arn
}
