#!/bin/bash

echo "Running database migration via ECS container..."

cd infrastructure

# Get the running task ARN
echo "Finding running ECS task..."
TASK_ARN=$(aws ecs list-tasks --cluster cwc-cluster --service-name cwc-service --query 'taskArns[0]' --output text)

if [ -z "$TASK_ARN" ] || [ "$TASK_ARN" = "None" ]; then
    echo "Error: No running ECS task found. Make sure the service is deployed and running."
    exit 1
fi

echo "Using task: $TASK_ARN"

# Run migration inside the ECS container
echo "Executing migration in ECS container..."
aws ecs execute-command \
    --cluster cwc-cluster \
    --task "$TASK_ARN" \
    --container cwc-app \
    --interactive \
    --command "bash -c 'cd /app && mysql -h \$(cat .env | grep RDS_ENDPOINT | cut -d= -f2) -u admin -p\$(aws secretsmanager get-secret-value --secret-id \$(cat .env | grep SECRET_NAME | cut -d= -f2) --query SecretString --output text | jq -r .password) cwc_catalog < migrations/init_vehicles.sql && echo Migration completed successfully'"

if [ $? -eq 0 ]; then
    echo "Migration executed successfully!"
else
    echo "Migration failed!"
    exit 1
fi