# Backend configuration for staging
bucket         = "your-terraform-state-bucket-staging"
key            = "blue-green-deployment/staging/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-state-locks-staging"
encrypt        = true
