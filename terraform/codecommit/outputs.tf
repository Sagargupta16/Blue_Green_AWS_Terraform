output "aws_codecommit_repository_name" {
  description = "Repository name."
  value       = aws_codecommit_repository.repo.repository_name
}

output "aws_codecommit_repository_arn" {
  description = "Repository ARN."
  value       = aws_codecommit_repository.repo.arn
}
