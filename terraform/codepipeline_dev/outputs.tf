output "pipeline_name" {
  description = "Dev pipeline name."
  value       = aws_codepipeline.main.name
}
