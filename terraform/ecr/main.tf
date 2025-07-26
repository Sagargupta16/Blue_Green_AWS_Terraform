data "aws_kms_alias" "kmskey" {
  name = var.kms_key_alias
}

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

