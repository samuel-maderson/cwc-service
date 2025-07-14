resource "aws_db_subnet_group" "main" {
  name       = var.db_subnet_group_name
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = var.db_subnet_group_name
  }
}

resource "aws_security_group" "rds" {
  name_prefix = "${var.cluster_name}-rds"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.ecs_security_group_id]
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.bastion_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-rds-sg"
  }
}

resource "random_id" "secret_suffix" {
  byte_length = 4
}

resource "aws_secretsmanager_secret" "db_master" {
  name = "cwc-db-prod-${random_id.secret_suffix.hex}"
  description = "Master credentials for CWC prod database"
}

resource "aws_secretsmanager_secret_version" "db_master" {
  secret_id = aws_secretsmanager_secret.db_master.id
  secret_string = jsonencode({
    username = var.master_username
    password = random_password.master.result
  })
}

resource "random_password" "master" {
  length  = 16
  special = false
}

resource "aws_db_instance" "main" {
  identifier                    = var.cluster_identifier
  engine                        = "mysql"
  engine_version                = "8.0"
  instance_class                = "db.t3.micro"
  allocated_storage             = 20
  storage_type                  = "gp2"
  db_name                       = var.database_name
  username                      = var.master_username
  password                      = random_password.master.result
  db_subnet_group_name          = aws_db_subnet_group.main.name
  vpc_security_group_ids        = [aws_security_group.rds.id]
  skip_final_snapshot           = true

  tags = {
    Name = var.cluster_identifier
  }
}