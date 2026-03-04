# Generate Random Password for RDS
resource "random_password" "trustify-db-admin-password" {
  count   = var.create_rds ? 1 : 0
  length  = 32
  special = false  # Only alphanumeric characters
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  count      = var.create_rds ? 1 : 0
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "main" {
  count                  = var.create_rds ? 1 : 0
  identifier             = "${var.project_name}-postgres"
  db_name                = var.db_name
  engine                 = "postgres"
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  storage_type           = "gp3"
  storage_encrypted      = true
  username               = var.db_master_user
  password               = random_password.trustify-db-admin-password[0].result
  ca_cert_identifier     = "rds-ca-rsa4096-g1"
  skip_final_snapshot    = true
  multi_az               = false
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds[0].id]
  db_subnet_group_name   = aws_db_subnet_group.main[0].name

  tags = {
    Name = "${var.project_name}-postgres"
  }
}
