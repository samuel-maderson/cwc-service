# CWC Vehicle Catalog API

A secure REST API for querying vehicle catalog data with JWT authentication and comprehensive vehicle information.

## Architecture

![CWC API Architecture](docs/images/cwc-api-architecture.png)

Our architecture is designed with enterprise-grade reliability and performance in mind:

- **Fault-Tolerant Multi-AZ Deployment** - Services distributed across three Availability Zones ensuring continuous operation even if an entire zone fails
- **Dynamic Auto-scaling** - ECS Fargate containers automatically adjust capacity based on traffic patterns and demand
- **Managed Relational Database** - RDS MySQL with Multi-AZ replication for data durability and high availability
- **Resilient Object Storage** - S3 for vehicle images with durability and cross-region replication capability
- **Enterprise Monitoring Solution** - CloudWatch dashboards with real-time metrics, custom alarms, and automated notifications

### Development
- **VPC** with public subnets
- **RDS MySQL** (publicly accessible for direct connection)
- **Local Docker** container
- **Direct database** access for development

### Production
- **VPC** with public/private subnets across 3 Availability Zones
- **Application Load Balancer** (public) for traffic distribution
- **ECS Fargate** (private subnets) with tasks distributed across AZs
- **RDS MySQL** (private subnets) with multi-AZ option
- **Bastion Host** for secure database access
- **ECR** for container images
- **S3** for vehicle images

## Features

- **JWT Authentication** - Secure API access with token-based authentication
- **Vehicle Catalog** - Query and list vehicles from database
- **AWS Integration** - Uses RDS MySQL, S3 for images, Secrets Manager for credentials
- **Multi-Environment** - Supports development and production deployments
- **Containerized** - Docker-based deployment with ECS Fargate
- **Infrastructure as Code** - Terraform-managed AWS infrastructure

## API Endpoints

### Authentication
- `POST /login` - Authenticate and get JWT token

### Vehicle Operations (all require JWT)
- `GET /vehicles` - List all vehicles
- `GET /vehicles/<id>` - Get specific vehicle
- `POST /vehicles` - Create a new vehicle
- `PUT /vehicles/<id>` - Update an existing vehicle
- `DELETE /vehicles/<id>` - Delete a vehicle

### System
- `GET /health` - Health check (public)

For detailed API documentation including request/response formats, examples, and error handling, see the `/` endpoint which serves the `index.html` documentation.

## Local Development

### Prerequisites

- AWS CLI configured
- Docker installed
- MySQL client (`brew install mysql`)
- Terraform installed

### Deploy Development Environment

```bash
# Run the deployment script
./bin/local_clean_test_deploy.sh

# Select:
# 1) Development (dev)
# 1) Clean and deploy
# Enter encryption key when prompted
```

This will:
- Deploy AWS infrastructure (VPC, RDS, S3, ECR, Secrets Manager)
- Build Docker image locally
- Start container on port 80
- Run database migration
- Upload sample images to S3

### Test Locally

```bash
# 1. Get authentication token
curl -X POST http://localhost/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "<password_from_secrets_manager>"}'

# 2. Use token to access vehicles
curl http://localhost/vehicles \
  -H "Authorization: Bearer <your_jwt_token>"

# 3. Get specific vehicle
curl http://localhost/vehicles/1 \
  -H "Authorization: Bearer <your_jwt_token>"

# 4. Create a new vehicle
curl -X POST http://localhost/vehicles \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <your_jwt_token>" \
  -d '{
    "make": "Example Brand",
    "model": "New Model",
    "year": 2024,
    "price": 45995.00,
    "image_url": "https://example.com/image.jpg"
  }'

# 5. Update a vehicle
curl -X PUT http://localhost/vehicles/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <your_jwt_token>" \
  -d '{
    "price": 46995.00
  }'

# 6. Delete a vehicle
curl -X DELETE http://localhost/vehicles/1 \
  -H "Authorization: Bearer <your_jwt_token>"

# 7. Health check (no auth required)
curl http://localhost/health
```

## Production Deployment

### GitHub Actions

Production deployment is automated via GitHub Actions workflow defined in `.github/workflows/deploy.yml`. The workflow is triggered automatically on every push to the `main` branch, ensuring continuous deployment of the latest changes.

The deployment process includes:
1. Infrastructure provisioning with Terraform
2. Docker image building and pushing to ECR
3. ECS service update with the new container image
4. Database migration (only runs if needed)

**Required Secrets:**
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY` 
- `ENCRYPTION_KEY`

**Required Variables:**
- `DEPLOY_ENVIRONMENT` (set to "prod")

The workflow can also be manually triggered using GitHub's workflow_dispatch feature, allowing you to select specific jobs to run (infrastructure, docker, or migration).

### Manual Production Deploy

```bash
# Run deployment script
./bin/local_clean_test_deploy.sh

# Select:
# 2) Production (prod)
# 1) Clean and deploy
# Enter encryption key when prompted
```

## Authentication

### Get API Credentials

Credentials are stored in AWS Secrets Manager:

```bash
# Get secret name
cd infrastructure
terraform output api_auth_secret_name

# Retrieve credentials
aws secretsmanager get-secret-value \
  --secret-id <secret_name> \
  --query SecretString --output text | jq .
```

### Generate JWT Token

```bash
# Login request
curl -X POST <api_url>/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "<password_from_secrets_manager>"
  }'

# Response:
# {"token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."}
```

### Use JWT Token

```bash
# Include token in Authorization header
curl <api_url>/vehicles \
  -H "Authorization: Bearer <jwt_token>"
```

### Test Production

```bash
# Get ALB DNS name from Terraform output
cd infrastructure
terraform output api_url

# Test endpoints (replace <alb_dns> with actual DNS)
curl -X POST https://<alb_dns>/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "<password_from_secrets_manager>"}'

curl https://<alb_dns>/vehicles \
  -H "Authorization: Bearer <your_jwt_token>"
```

## Configuration

### Environment Variables

- **Local Development**: Uses `.env` file generated by deployment script
- **Production**: Uses ECS task definition environment variables

The `.env` file is only necessary for local development. In production, all configuration is managed through ECS task environment variables populated from Terraform outputs and AWS Secrets Manager.

### Security

- **Encrypted Secrets** - Terraform files with credentials are encrypted
- **JWT Authentication** - All vehicle endpoints require valid JWT token
- **AWS Secrets Manager** - Database and API credentials stored securely
- **VPC Isolation** - Production resources in private subnets
- **IAM Roles** - Least privilege access for ECS tasks

### Monitoring and Alerts

![CloudWatch Dashboard](docs/images/cw-dashboard-1.png)

The application includes comprehensive monitoring and alerting through CloudWatch:

#### CloudWatch Dashboard
- **ECS Service CPU Utilization** - Real-time CPU usage of ECS tasks
- **ECS Service Memory Utilization** - Memory consumption of ECS tasks
- **ALB Response Codes** - HTTP response codes (2XX, 4XX, 5XX) from the load balancer
- **ALB Response Time** - Average response time for API requests
- **RDS CPU & Connections** - Database CPU usage and active connections
- **RDS Storage & IOPS** - Database storage space and I/O operations

#### CloudWatch Alarms
- **ECS CPU Alarm** - Triggers when CPU utilization exceeds 50% for 10 minutes
- **ECS Memory Alarm** - Triggers when memory utilization exceeds 50% for 10 minutes
- **RDS CPU Alarm** - Triggers when database CPU exceeds 50% for 10 minutes

All alarms send notifications to a designated email address via SNS.

## Troubleshooting

### Common Issues

1. **Authentication Failed**
   - Check credentials in Secrets Manager
   - Ensure JWT token is valid and not expired

2. **Database Connection**
   - Verify RDS endpoint and security groups
   - Check Secrets Manager for database password

3. **Container Issues**
   - Check ECS logs in CloudWatch
   - Verify environment variables in task definition

### Logs

```bash
# View container logs
aws logs tail /ecs/cwc-cluster/app --follow

# View specific log stream
aws logs describe-log-streams --log-group-name /ecs/cwc-cluster/app
```