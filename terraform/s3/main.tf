resource "random_pet" "bucket_name" {
  length    = 2
  separator = "-"
}

resource "aws_s3_bucket" "artifact_bucket" {
  bucket        = "${var.name}-artifact-bucket-${random_pet.bucket_name.id}"
  force_destroy = true
}
