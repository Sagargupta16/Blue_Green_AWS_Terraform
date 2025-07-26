# Backend configuration for development
bucket         = "your-terraform-state-bucket-dev"
key            = "blue-green-deployment/dev/terraform.tfstate"
region         = "us-west-2"
dynamodb_table = "terraform-state-locks-dev"
encrypt        = true
