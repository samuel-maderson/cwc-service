# CloudWatch Monitoring Module

This module sets up CloudWatch monitoring for the CWC Vehicle Catalog API, including:

1. A comprehensive CloudWatch dashboard with metrics for:
   - ECS service (CPU, memory, task count)
   - Application Load Balancer (response codes, response time)
   - RDS database (CPU, connections, storage, IOPS)

2. CloudWatch alarms with email notifications for:
   - ECS CPU utilization > 50%
   - ECS memory utilization > 50%
   - RDS CPU utilization > 50%
   - No running ECS tasks
   - ALB 5XX errors > 5 in a minute

## Usage

```hcl
module "monitoring" {
  source = "./modules/monitoring"

  environment    = "prod"
  aws_region     = "us-east-1"
  cluster_name   = "cwc-cluster"
  service_name   = "cwc-service"
  alb_arn_suffix = module.alb.alb_arn_suffix
  db_instance_id = module.rds.db_instance_id
  alert_email    = "your-email@example.com"
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| environment | Environment name (e.g., dev, prod) | string | - |
| aws_region | AWS region | string | - |
| cluster_name | ECS cluster name | string | - |
| service_name | ECS service name | string | - |
| alb_arn_suffix | ARN suffix of the ALB | string | - |
| db_instance_id | RDS instance identifier | string | - |
| alert_email | Email address to send alerts to | string | "samuel.maderson@gmail.com" |

## Outputs

| Name | Description |
|------|-------------|
| dashboard_url | URL to the CloudWatch dashboard |
| sns_topic_arn | ARN of the SNS topic for alerts |

## Notes

- When first deployed, you will receive a subscription confirmation email that you must accept to receive alerts.
- The dashboard is accessible via the AWS Console or through the dashboard_url output.
- All alarms are configured to send both alarm and OK notifications.