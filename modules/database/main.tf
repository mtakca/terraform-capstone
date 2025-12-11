resource "aws_security_group" "db" {
  name        = "${var.name_prefix}-db-sg"
  description = "Security Group for Database"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-db-sg" })
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = merge(var.tags, { Name = "${var.name_prefix}-db-subnet-group" })
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_"
}

resource "aws_secretsmanager_secret" "db_pass" {
  name_prefix = "${var.name_prefix}-db-pass-"
  description = "Generic database password"
  tags        = merge(var.tags, { Name = "${var.name_prefix}-db-secret" })
}

resource "aws_secretsmanager_secret_version" "db_pass_val" {
  secret_id     = aws_secretsmanager_secret.db_pass.id
  secret_string = random_password.password.result
}

# --- Primary Instance ---
resource "aws_db_instance" "primary" {
  identifier           = "${var.name_prefix}-primary"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro" # Changed to micro for broader compatibility
  allocated_storage    = 20
  
  db_name              = var.db_name
  username             = var.db_username
  password             = random_password.password.result
  
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  
  multi_az               = true # High Availability
  storage_encrypted      = true
  skip_final_snapshot    = true
  
  backup_retention_period = 1 # Enable backups (required for replicas)

  tags = merge(var.tags, { Name = "${var.name_prefix}-primary" })
}

# --- Read Replica (Optional but Architecture Compliant) ---
resource "aws_db_instance" "replica" {
  count                = 1 # 1 Replica
  identifier           = "${var.name_prefix}-replica"
  replicate_source_db  = aws_db_instance.primary.identifier
  instance_class       = "db.t3.micro"
  
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.db.id]
  
  tags = merge(var.tags, { Name = "${var.name_prefix}-replica" })
}
