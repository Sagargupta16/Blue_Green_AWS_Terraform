locals {
  # Common tags merged with project-specific metadata
  common_tags = merge(
    var.common_tags,
    {
      ProjectName   = var.project_name
      CreatedBy     = "Terraform"
      Repository    = "Blue_Green_AWS_Terraform"
      Branch        = "feature/modifications"
      ResourceGroup = var.project_name
    }
  )
}
