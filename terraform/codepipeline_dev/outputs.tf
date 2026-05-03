################################################################################
# CodePipeline (Dev) Module - outputs.tf
################################################################################

output "pipeline_name" {
  description = "Name of the dev CodePipeline."
  value       = aws_codepipeline.main.name
}
