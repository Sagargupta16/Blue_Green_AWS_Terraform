# Remote state
#
# Partial S3 backend: the bucket, key and region come from backend.hcl, which
# the bootstrap/ module prints (copy backend.hcl.example and fill it in).
#
#   terraform init -backend-config=backend.hcl
#
# Coming from local state? Add -migrate-state once and Terraform copies
# terraform.tfstate into the bucket. CI runs `terraform init -backend=false`,
# so it never needs the bucket.

terraform {
  backend "s3" {}
}
