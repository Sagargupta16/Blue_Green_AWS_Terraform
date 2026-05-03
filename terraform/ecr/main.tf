################################################################################
# ECR Module - main.tf
#
# Private ECR repository for application container images. Images are
# encrypted with the pipeline KMS key (looked up via alias) and scanned on
# push.
################################################################################


################################################################################
# Data sources
################################################################################

data "aws_kms_alias" "kmskey" {
  name = var.kms_key_alias
}


################################################################################
# Repository
################################################################################

resource "aws_ecr_repository" "repo" {
  name         = "${var.name}-ecr-repo"
  force_delete = true

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = data.aws_kms_alias.kmskey.arn
  }
}
