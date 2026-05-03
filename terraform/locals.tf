################################################################################
# Root locals.tf
#
# Builds the tag set applied to every module by merging the user-supplied
# common_tags map with project metadata.
################################################################################

locals {
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
