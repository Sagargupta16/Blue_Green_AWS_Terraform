# State bucket bootstrap, on a mocked provider (no AWS account needed).
# Run from terraform/bootstrap/: terraform test

mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "111122223333"
    }
  }

  mock_resource "aws_s3_bucket" {
    defaults = {
      arn = "arn:aws:s3:::blue-green-dep-app-tfstate-111122223333"
    }
  }
}

run "bucket_is_locked_down" {
  assert {
    condition     = aws_s3_bucket.state.bucket == "blue-green-dep-app-tfstate-111122223333"
    error_message = "Default bucket name should be <project>-tfstate-<account id>."
  }

  assert {
    condition     = aws_s3_bucket_versioning.state.versioning_configuration[0].status == "Enabled"
    error_message = "State versions are the only undo for a bad apply; versioning must be on."
  }

  assert {
    condition = alltrue([
      aws_s3_bucket_public_access_block.state.block_public_acls,
      aws_s3_bucket_public_access_block.state.block_public_policy,
      aws_s3_bucket_public_access_block.state.ignore_public_acls,
      aws_s3_bucket_public_access_block.state.restrict_public_buckets,
    ])
    error_message = "All four public access blocks must be on."
  }

  assert {
    condition     = one([for r in aws_s3_bucket_server_side_encryption_configuration.state.rule : r.apply_server_side_encryption_by_default[0].sse_algorithm]) == "aws:kms"
    error_message = "State must be encrypted with SSE-KMS."
  }

  assert {
    condition     = jsondecode(aws_s3_bucket_policy.state.policy).Statement[0].Condition.Bool["aws:SecureTransport"] == "false"
    error_message = "The bucket policy must deny non-TLS requests."
  }

  assert {
    condition     = aws_s3_bucket_logging.state.target_bucket == aws_s3_bucket.access_logs.id
    error_message = "State bucket access logs must go to the access-log bucket."
  }

  assert {
    condition     = one([for r in aws_s3_bucket_server_side_encryption_configuration.access_logs.rule : r.apply_server_side_encryption_by_default[0].sse_algorithm]) == "AES256"
    error_message = "S3 server access logs are delivered only to SSE-S3 buckets."
  }

  assert {
    condition     = jsondecode(aws_s3_bucket_policy.access_logs.policy).Statement[0].Condition.StringEquals["aws:SourceAccount"] == "111122223333"
    error_message = "Log delivery must be scoped to this account."
  }
}

run "backend_hcl_matches_the_bucket" {
  assert {
    condition     = strcontains(output.backend_hcl, "bucket       = \"blue-green-dep-app-tfstate-111122223333\"")
    error_message = "backend_hcl must name the bucket this module created."
  }

  assert {
    condition     = strcontains(output.backend_hcl, "use_lockfile = true")
    error_message = "backend_hcl must turn on S3 native locking."
  }
}

run "bucket_name_override" {
  variables {
    bucket_name = "my-team-tfstate"
  }

  assert {
    condition     = aws_s3_bucket.state.bucket == "my-team-tfstate"
    error_message = "bucket_name should override the derived name."
  }
}
