#!/bin/bash

# Terraform initialization script with backend configuration
# Usage: ./init.sh [environment]
# Example: ./init.sh dev

ENVIRONMENT=${1:-prod}
BACKEND_CONFIG="backend"

if [ "$ENVIRONMENT" != "prod" ]; then
    BACKEND_CONFIG="backend-${ENVIRONMENT}"
fi

echo "Initializing Terraform with ${ENVIRONMENT} backend configuration..."

if [ -f "${BACKEND_CONFIG}.hcl" ]; then
    terraform init -backend-config="${BACKEND_CONFIG}.hcl"
else
    echo "Backend configuration file ${BACKEND_CONFIG}.hcl not found!"
    echo "Available configurations:"
    ls -la backend*.hcl 2>/dev/null || echo "No backend configuration files found"
    exit 1
fi

echo "Terraform initialized successfully for ${ENVIRONMENT} environment!"
