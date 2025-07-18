#!/bin/bash

echo "Choose environment:"
echo "1) Development (dev)"
echo "2) Production (prod)"
read -p "Enter environment choice (1 or 2): " env_choice

if [ "$env_choice" = "1" ]; then
    ENVIRONMENT="dev"
elif [ "$env_choice" = "2" ]; then
    ENVIRONMENT="prod"
else
    echo "Invalid environment choice. Exiting."
    exit 1
fi

echo "Selected environment: $ENVIRONMENT"
echo ""
echo "Choose deployment type:"
echo "1) Clean and deploy (removes existing state)"
echo "2) Simple deploy (keeps existing state)"
read -p "Enter your choice (1, 2): " choice

# Decrypt secrets before deployment
read -s -p "Enter encryption key: " ENCRYPTION_KEY
echo ""
./bin/decrypt_secrets.sh "$ENCRYPTION_KEY"

cd infrastructure

# Ensure backend infrastructure exists
echo "Checking Terraform backend..."
aws cloudformation describe-stacks --stack-name cwc-terraform-backend --region us-east-1 > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Backend not found. Setting up..."
    cd ..
    ./bin/setup_backend.sh
    cd infrastructure
fi

if [ "$choice" = "1" ]; then
    echo "Performing clean deployment..."
    rm -rf .terraform*
    terraform init -upgrade
elif [ "$choice" = "2" ]; then
    echo "Performing simple deployment..."
    terraform init -upgrade
else
    echo "Invalid choice. Exiting."
    exit 1
fi

terraform apply -var="environment=$ENVIRONMENT" --auto-approve

# Generate .env file with terraform outputs
echo "Generating .env file..."
if [ "$ENVIRONMENT" = "dev" ]; then
    RDS_ENDPOINT=$(terraform output -raw rds_dev_endpoint | sed 's/:3306$//')
    SECRET_NAME=$(terraform output -raw rds_dev_secret_name)
else
    RDS_ENDPOINT=$(terraform output -raw rds_endpoint | sed 's/:3306$//')
    SECRET_NAME=$(terraform output -raw rds_secret_name)
fi

echo "Using RDS Endpoint: $RDS_ENDPOINT"
echo "Using Secret Name: $SECRET_NAME"

cat > ../src/.env << EOF
ENVIRONMENT=$ENVIRONMENT
AWS_REGION=us-east-1
RDS_ENDPOINT=$RDS_ENDPOINT
SECRET_NAME=$SECRET_NAME
API_AUTH_SECRET_NAME=$(terraform output -raw api_auth_secret_name)
S3_BUCKET_NAME=$(terraform output -raw s3_bucket_name)
ECR_REPOSITORY_URL=$(terraform output -raw ecr_repository_url)
EOF

echo ".env file created successfully"
cd ..
if [ "$ENVIRONMENT" = "prod" ]; then
    # Get ECR repository URL from terraform output
    cd infrastructure
    ECR_URL=$(terraform output -raw ecr_repository_url)
    cd ..
    if [ -z "$ECR_URL" ]; then
        echo "Error: Could not get ECR repository URL"
        exit 1
    fi

    echo "Building and pushing Docker image to ECR: $ECR_URL"
    # Login to ECR
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URL

    # Build and push
    docker build --platform linux/amd64 -t cwc-service .
    docker tag cwc-service:latest $ECR_URL:latest
    docker push $ECR_URL:latest
    echo "Docker image pushed successfully to ECR"
else
    echo "Building Docker image locally for dev environment"
    docker build -t cwc-service:latest .
    echo "Docker image built successfully for local use"
    
    echo "Starting container on port 80..."
    docker run -dit --rm --name cwc-service -p 80:80 cwc-service:latest
    echo "Container started at http://localhost"
    
    echo "Running database migration..."
    PASSWORD=$(aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --query SecretString --output text | jq -r .password)
    mysql -h $RDS_ENDPOINT --default-auth=mysql_native_password -uadmin -p$PASSWORD cwc_catalog < src/migrations/init_vehicles.sql
    echo "Migration completed successfully!"
fi

cd infrastructure
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