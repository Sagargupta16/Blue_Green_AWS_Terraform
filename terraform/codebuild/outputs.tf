################################################################################
# CodeBuild Module - outputs.tf
################################################################################

output "codebuild_project_name" {
  description = "Name of the CodeBuild project (consumed by the CodePipeline Build stage)."
  value       = aws_codebuild_project.build.name
}
