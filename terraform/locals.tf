# Locals

locals {
  common_tags = merge(
    var.common_tags,
    {
      ProjectName   = var.project_name
      CreatedBy     = "Terraform"
      Repository    = "terraform-aws-ecs-blue-green"
      Branch        = "feature/modifications"
      ResourceGroup = var.project_name
    }
  )
}
