################################################################################
# CodeCommit Module - outputs.tf  (DEPRECATED - kept for historical reference)
################################################################################

output "aws_codecommit_repository_name" {
  description = "Name of the (unused) CodeCommit repository."
  value       = aws_codecommit_repository.repo.repository_name
}

output "aws_codecommit_repository_arn" {
  description = "ARN of the (unused) CodeCommit repository."
  value       = aws_codecommit_repository.repo.arn
}
