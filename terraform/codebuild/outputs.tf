output "codebuild_project_name" {
  description = "CodeBuild project name."
  value       = aws_codebuild_project.build.name
}
