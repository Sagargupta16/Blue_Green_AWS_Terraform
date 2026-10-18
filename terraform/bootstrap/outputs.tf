output "state_bucket" {
  description = "S3 bucket that holds the main stack's state."
  value       = aws_s3_bucket.state.bucket
}

output "backend_hcl" {
  description = "Contents for terraform/backend.hcl (terraform init -backend-config=backend.hcl)."
  value       = <<-EOT
    bucket       = "${aws_s3_bucket.state.bucket}"
    key          = "blue-green/terraform.tfstate"
    region       = "${var.aws_region}"
    encrypt      = true
    use_lockfile = true
  EOT
}
