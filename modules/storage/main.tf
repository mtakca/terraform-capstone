resource "aws_security_group" "efs" {
  name        = "${var.name_prefix}-efs-sg"
  description = "Security Group for EFS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-efs-sg" })
}

resource "aws_efs_file_system" "this" {
  creation_token = "${var.name_prefix}-efs-token"
  encrypted      = true

  tags = merge(var.tags, { Name = "${var.name_prefix}-efs" })
}

resource "aws_efs_mount_target" "this" {
  count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [aws_security_group.efs.id]
}
