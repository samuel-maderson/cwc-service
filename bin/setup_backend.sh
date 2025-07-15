#!/bin/bash

echo "Setting up Terraform remote state backend..."

# Deploy CloudFormation stack for S3 and DynamoDB
aws cloudformation deploy \
  --template-file infrastructure/terraform-backend.yml \
  --stack-name cwc-terraform-backend \
  --parameter-overrides ProjectName=cwc-service \
  --capabilities CAPABILITY_IAM \
  --region us-east-1

if [ $? -eq 0 ]; then
    echo "Backend infrastructure deployed successfully!"
    
    # Get outputs
    S3_BUCKET=$(aws cloudformation describe-stacks \
      --stack-name cwc-terraform-backend \
      --query 'Stacks[0].Outputs[?OutputKey==`S3BucketName`].OutputValue' \
      --output text)
    
    DYNAMODB_TABLE=$(aws cloudformation describe-stacks \
      --stack-name cwc-terraform-backend \
      --query 'Stacks[0].Outputs[?OutputKey==`DynamoDBTableName`].OutputValue' \
      --output text)
    
    echo "S3 Bucket: $S3_BUCKET"
    echo "DynamoDB Table: $DYNAMODB_TABLE"
    
    # Update backend.tf with the actual bucket name
    echo "Updating backend.tf..."
    cat > infrastructure/backend.tf << EOF
terraform {
  backend "s3" {
    bucket         = "$S3_BUCKET"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "$DYNAMODB_TABLE"
    encrypt        = true
  }
}
EOF
    
    echo "Backend configuration updated successfully!"
else
    echo "Failed to deploy backend infrastructure!"
    exit 1
fi