resource "aws_db_subnet_group" "main" {
  name       = "${var.db_subnet_group_name}-dev"
  subnet_ids = var.public_subnet_ids

  tags = {
    Name = "${var.db_subnet_group_name}-dev"
  }
}

resource "aws_security_group" "rds" {
  name_prefix = "${var.cluster_name}-rds-dev"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-rds-dev-sg"
  }
}

resource "aws_db_instance" "main" {
  identifier                    = "${var.cluster_identifier}-dev"
  engine                        = "mysql"
  engine_version                = "8.0"
  instance_class                = "db.t3.micro"
  allocated_storage             = 20
  storage_type                  = "gp2"
  db_name                       = var.database_name
  username                      = var.master_username
  manage_master_user_password   = true
  db_subnet_group_name          = aws_db_subnet_group.main.name
  vpc_security_group_ids        = [aws_security_group.rds.id]
  skip_final_snapshot           = true
  publicly_accessible          = true

  tags = {
    Name = "${var.cluster_identifier}-dev"
  }
}