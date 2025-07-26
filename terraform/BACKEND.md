# Backend Configuration Guide

## Overview

This project uses partial backend configuration to support multiple environments while working around Terraform's limitation that backend blocks cannot use variables.

## Backend Configuration Files

- `backend.hcl` - Production environment
- `backend-dev.hcl` - Development environment  
- `backend-staging.hcl` - Staging environment

## Usage

### Windows
```cmd
# Initialize for production (default)
init.bat

# Initialize for development
init.bat dev

# Initialize for staging
init.bat staging
```

### Linux/Mac
```bash
# Make script executable
chmod +x init.sh

# Initialize for production (default)
./init.sh

# Initialize for development
./init.sh dev

# Initialize for staging
./init.sh staging
```

### Manual Initialization
```bash
# Production
terraform init -backend-config="backend.hcl"

# Development
terraform init -backend-config="backend-dev.hcl"

# Staging
terraform init -backend-config="backend-staging.hcl"
```

## Backend Configuration Format

Each `.hcl` file should contain:

```hcl
bucket         = "your-terraform-state-bucket-{env}"
key            = "blue-green-deployment/{env}/terraform.tfstate"
region         = "us-west-2"
dynamodb_table = "terraform-state-locks-{env}"
encrypt        = true
```

## Prerequisites

Before using backend configuration, ensure you have:

1. **S3 Buckets** created for each environment
2. **DynamoDB Tables** created for state locking
3. **Proper IAM permissions** for Terraform to access these resources

### Create S3 Bucket and DynamoDB Table

```bash
# Create S3 bucket for state storage
aws s3 mb s3://your-terraform-state-bucket-prod --region us-west-2

# Create DynamoDB table for state locking
aws dynamodb create-table \
    --table-name terraform-state-locks-prod \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region us-west-2
```

## Security Considerations

- Backend configuration files may contain sensitive information
- Consider using environment variables or AWS profiles for credentials
- Never commit sensitive backend configurations to version control
- Use bucket policies and IAM roles for additional security

## Troubleshooting

### Common Issues

1. **Backend already initialized**: Run `terraform init -reconfigure`
2. **Permission denied**: Check IAM permissions for S3 and DynamoDB
3. **Bucket doesn't exist**: Create the S3 bucket first
4. **State locked**: Check DynamoDB for lock entries

### Reset Backend
```bash
# Remove existing backend state
rm -rf .terraform/

# Reinitialize with new backend
terraform init -backend-config="backend.hcl"
```
