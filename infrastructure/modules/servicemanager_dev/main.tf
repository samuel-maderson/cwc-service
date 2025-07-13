resource "aws_secretsmanager_secret_rotation" "db_password" {
  secret_id = var.rds_master_user_secret_arn

  rotation_rules {
    automatically_after_days = 30
  }
}