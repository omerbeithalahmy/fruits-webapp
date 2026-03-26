#!/bin/bash
set -e

echo "Fetching AWS Account ID to resolve secure S3 bucket name"
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
BUCKET_NAME="fruits-webapp-terraform-state-${ACCOUNT_ID}"

echo "Deploying Main Infrastructure Configuration"
echo "  Backend S3 Bucket: $BUCKET_NAME"

cd terraform

terraform init -backend-config="bucket=${BUCKET_NAME}"

terraform apply -auto-approve

echo "Deployment successful!"
echo "Please wait a few minutes for the EC2 instance to provision fully."
echo "You can view the application by accessing the ALB DNS name output above in your browser."
