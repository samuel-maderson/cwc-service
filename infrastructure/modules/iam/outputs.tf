output "app_role_arn" {
  description = "ARN of the application IAM role"
  value       = aws_iam_role.app_role.arn
}

output "app_role_name" {
  description = "Name of the application IAM role"
  value       = aws_iam_role.app_role.name
}