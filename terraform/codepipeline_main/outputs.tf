output "pipeline_name" {
  description = "Production pipeline name."
  value       = aws_codepipeline.main.name
}
