output "aws_codecommit_repository_name" {
  description = "The name of the codecommit repository"
  value       = aws_codecommit_repository.repo.repository_name
}

output "aws_codecommit_repository_arn" {
  description = "The ARN of the codecommit repository"
  value       = aws_codecommit_repository.repo.arn
}