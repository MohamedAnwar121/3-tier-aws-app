# ── Public ALB SG: internet → port 80 ────────────────────────────────────────
resource "aws_security_group" "public_alb" {
  name        = "${var.project}-${var.environment}-public-alb-sg"
  vpc_id      = var.vpc_id
  description = "Public ALB - allows HTTP from internet"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project}-${var.environment}-public-alb-sg" }
}

# ── Frontend SG: only from public ALB ────────────────────────────────────────
resource "aws_security_group" "frontend" {
  name        = "${var.project}-${var.environment}-frontend-sg"
  vpc_id      = var.vpc_id
  description = "Frontend EC2 - allows traffic from public ALB only"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.public_alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project}-${var.environment}-frontend-sg" }
}

# ── Internal ALB SG: from frontend only ──────────────────────────────────────
resource "aws_security_group" "internal_alb" {
  name        = "${var.project}-${var.environment}-internal-alb-sg"
  vpc_id      = var.vpc_id
  description = "Internal ALB - allows traffic from frontend tier only"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project}-${var.environment}-internal-alb-sg" }
}

# ── Backend SG: from internal ALB only ───────────────────────────────────────
resource "aws_security_group" "backend" {
  name        = "${var.project}-${var.environment}-backend-sg"
  vpc_id      = var.vpc_id
  description = "Backend EC2 - allows traffic from internal ALB only"

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project}-${var.environment}-backend-sg" }
}

# ── RDS SG: from backend only ─────────────────────────────────────────────────
resource "aws_security_group" "rds" {
  name        = "${var.project}-${var.environment}-rds-sg"
  vpc_id      = var.vpc_id
  description = "RDS - allows PostgreSQL from backend tier only"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.backend.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project}-${var.environment}-rds-sg" }
}
