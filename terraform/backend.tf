terraform {
  # Partial backend configuration - values provided via CLI or backend config file
  backend "s3" {
    # These values will be provided via terraform init -backend-config
    # or via a backend.hcl file
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
  required_version = ">= 1.0.0"
}
