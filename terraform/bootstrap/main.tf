# Remote state bootstrap
#
# A separate root module with its own local state, applied once per account
# before the main stack. It creates the S3 bucket the main stack keeps its
# state in. Locking uses S3 native lock files (use_lockfile, Terraform 1.10+),
# so no DynamoDB table is needed.

terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      ProjectName = var.project_name
      Purpose     = "terraform-state"
      ManagedBy   = "Terraform"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  # Account ID keeps the global bucket name unique without a random suffix,
  # so the name is predictable for backend.hcl.
  bucket_name = coalesce(var.bucket_name, "${var.project_name}-tfstate-${data.aws_caller_identity.current.account_id}")
}


# State bucket

resource "aws_s3_bucket" "state" {
  #checkov:skip=CKV_AWS_18:Access logs need a second bucket; use CloudTrail S3 data events to audit state reads
  #checkov:skip=CKV_AWS_144:One small state bucket; versioning covers bad applies, cross-region replication is out of scope
  #checkov:skip=CKV2_AWS_62:Nothing consumes state-bucket event notifications
  bucket = local.bucket_name

  # Losing this bucket loses every environment's state.
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    id     = "expire-old-state-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_policy" "state" {
  bucket = aws_s3_bucket.state.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "DenyInsecureTransport"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:*"
      Resource  = [aws_s3_bucket.state.arn, "${aws_s3_bucket.state.arn}/*"]
      Condition = {
        Bool = { "aws:SecureTransport" = "false" }
      }
    }]
  })

  depends_on = [aws_s3_bucket_public_access_block.state]
}
