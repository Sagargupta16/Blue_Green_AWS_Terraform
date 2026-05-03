################################################################################
# S3 Module - main.tf
#
# Shared artifact bucket used by CodeBuild and CodePipeline as the store for
# source/build/deploy artifacts. The suffix is a random pet name so the bucket
# global-namespace collision risk is low.
#
# force_destroy = true lets `terraform destroy` wipe the bucket even if it
# still contains objects - convenient for ephemeral demos, but remove it
# before using this module in production.
################################################################################


################################################################################
# Helper: random suffix for bucket name
################################################################################

resource "random_pet" "bucket_name" {
  length    = 2
  separator = "-"
}


################################################################################
# Bucket
################################################################################

resource "aws_s3_bucket" "artifact_bucket" {
  bucket        = "${var.name}-artifact-bucket-${random_pet.bucket_name.id}"
  force_destroy = true

  tags = merge(var.tags, {
    Name      = "${var.name}-artifact-bucket-${random_pet.bucket_name.id}"
    Purpose   = "CI/CD Artifacts"
    Service   = "S3"
    Component = "Storage"
  })
}
