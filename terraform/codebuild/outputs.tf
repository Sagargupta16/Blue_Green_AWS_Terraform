output "codebuild_project_name" {
  description = "The name of the codebuild project"
  value       = aws_codebuild_project.build.name
}