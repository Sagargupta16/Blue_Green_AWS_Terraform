output "pipeline_name" {
  description = "The name of the codepipeline"
  value       = aws_codepipeline.main.name
}
