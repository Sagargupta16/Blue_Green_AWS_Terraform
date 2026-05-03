################################################################################
# CodePipeline (Main) Module - outputs.tf
################################################################################

output "pipeline_name" {
  description = "Name of the production CodePipeline."
  value       = aws_codepipeline.main.name
}
