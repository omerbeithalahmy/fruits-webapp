#!/bin/bash
set -e

echo "Initializing Terraform Backend Resources"

cd terraform/backend
terraform init
terraform apply -auto-approve

echo "Backend provisioning completed successfully."
