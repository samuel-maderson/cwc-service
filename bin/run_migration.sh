#!/bin/bash

echo "Running database migration..."

cd infrastructure

# Get RDS endpoint from terraform output
ENDPOINT=$(terraform output -raw rds_dev_endpoint)

if [ -z "$ENDPOINT" ]; then
    echo "Error: Could not get RDS endpoint. Make sure infrastructure is deployed."
    exit 1
fi

# Remove :3306 port if present
ENDPOINT=$(echo $ENDPOINT | sed 's/:3306$//')
echo "Clean endpoint: $ENDPOINT"

# Get secret name from terraform output
SECRET_NAME=$(terraform output -raw rds_dev_secret_name)

if [ -z "$SECRET_NAME" ] || [ "$SECRET_NAME" = "null" ]; then
    echo "Error: Could not get secret name from terraform output."
    exit 1
fi

echo "Using secret: $SECRET_NAME"

# Get password from Secrets Manager
echo "Retrieving password from Secrets Manager..."
PASSWORD=$(aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --query SecretString --output text | jq -r .password)

if [ -z "$PASSWORD" ]; then
    echo "Error: Could not retrieve password from Secrets Manager."
    exit 1
fi

echo "Connecting to database: $ENDPOINT"

# Run the migration
mysql -h $ENDPOINT --skip-ssl --default-auth=mysql_native_password -uadmin -p$PASSWORD < ../src/migrations/init_vehicles.sql

if [ $? -eq 0 ]; then
    echo "Migration completed successfully!"
else
    echo "Migration failed!"
    exit 1
fi