# Backend configuration for production
bucket         = "your-terraform-state-bucket-prod"
key            = "blue-green-deployment/terraform.tfstate"
region         = "us-west-2"
dynamodb_table = "terraform-state-locks-prod"
encrypt        = true
