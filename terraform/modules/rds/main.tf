resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-${var.environment}-db-subnet-group"
  subnet_ids = var.db_subnet_ids
  tags       = { Name = "${var.project}-${var.environment}-db-subnet-group" }
}

resource "aws_db_instance" "main" {
  identifier             = "${var.project}-${var.environment}-rds"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = var.db_instance_class
  allocated_storage      = 20
  storage_type           = "gp3"
  storage_encrypted      = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_sg_id]

  # Multi-AZ for standby replica in second AZ
  multi_az               = true
  publicly_accessible    = false

  backup_retention_period = 7
  deletion_protection     = false   # set true in real prod
  skip_final_snapshot     = true

  tags = { Name = "${var.project}-${var.environment}-rds" }
}
