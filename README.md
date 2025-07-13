# cwc-service
## Vehicle Catalog API

A REST API for querying and listing vehicle catalog with comprehensive vehicle information.

## Features
- Query and list Volkswagen vehicles from catalog
- Comprehensive vehicle data model with relevant sales information
- RESTful endpoints for vehicle catalog operations

## Development Environment

The development environment deploys minimal infrastructure optimized for local testing and development. It creates only the essential components: VPC networking and a publicly accessible RDS MySQL instance. This setup allows developers to connect directly to the database from their local machines without requiring VPN or bastion host access.

### Deploy Development Infrastructure

```bash
cd infrastructure
terraform init
terraform apply -var="environment=dev"
```

### Connect to Development Database

Once deployed, you can connect directly to the RDS instance from your local machine:

```bash
# Install MySQL client (Mac)
brew install mysql

# Get the database endpoint
terraform output rds_dev_endpoint

# Connect to dev database
mysql -h <rds_dev_endpoint> --skip-ssl --default-auth=mysql_native_password -uadmin -p

# Alternative with MariaDB client (recommended for better compatibility)
brew install mariadb
mariadb -h <rds_dev_endpoint> -uadmin -p --skip-ssl
```

The development RDS instance uses AWS Secrets Manager for password management with automatic 30-day rotation. Retrieve the current password from AWS Secrets Manager console or use the AWS CLI to get credentials programmatically.
