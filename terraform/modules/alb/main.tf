# ── Public ALB (internet-facing → frontend) ───────────────────────────────────
resource "aws_lb" "public" {
  name               = "${var.project}-${var.environment}-public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.public_alb_sg_id]
  subnets            = var.public_subnets
  tags               = { Name = "${var.project}-${var.environment}-public-alb" }
}

resource "aws_lb_target_group" "frontend" {
  name     = "${var.project}-${var.environment}-frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "public_http" {
  load_balancer_arn = aws_lb.public.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# ── Internal ALB (frontend → backend) ────────────────────────────────────────
resource "aws_lb" "internal" {
  name               = "${var.project}-${var.environment}-internal-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.internal_alb_sg_id]
  subnets            = var.frontend_subnets
  tags               = { Name = "${var.project}-${var.environment}-internal-alb" }
}

resource "aws_lb_target_group" "backend" {
  name     = "${var.project}-${var.environment}-backend-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "internal_http" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}
