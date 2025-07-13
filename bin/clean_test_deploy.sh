#!/bin/bash

echo "Choose deployment type:"
echo "1) Clean and deploy (removes existing state)"
echo "2) Simple deploy (keeps existing state)"
read -p "Enter your choice (1 or 2): " choice

cd infrastructure

if [ "$choice" = "1" ]; then
    echo "Performing clean deployment..."
    rm -rf .terraform*
    rm -f terraform.tfstate*
    terraform init -upgrade
elif [ "$choice" = "2" ]; then
    echo "Performing simple deployment..."
    terraform init -upgrade
else
    echo "Invalid choice. Exiting."
    exit 1
fi

terraform apply -var="environment=dev" --auto-approve

BUCKET_NAME=$(terraform output -json | jq -r .s3_bucket_name.value)
echo "S3 Bucket: $BUCKET_NAME"

if [ -d "../src/imgs/" ]; then
    echo "Uploading images to S3..."
    aws s3 sync ../src/imgs/ s3://$BUCKET_NAME --delete
    echo "Images uploaded successfully"
else
    echo "No imgs directory found, skipping image upload"
fi

terraform output -json | jq .api_url.value