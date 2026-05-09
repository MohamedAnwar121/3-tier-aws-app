# ── IAM role for EC2 instances (SSM + Vault auth) ────────────────────────────
# resource "aws_iam_role" "ec2" {
#   name = "${var.project}-${var.environment}-ec2-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action    = "sts:AssumeRole"
#       Effect    = "Allow"
#       Principal = { Service = "ec2.amazonaws.com" }
#     }]
#   })
# }

# resource "aws_iam_role_policy_attachment" "ssm" {
#   role       = aws_iam_role.ec2.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

# resource "aws_iam_instance_profile" "ec2" {
#   name = "${var.project}-${var.environment}-ec2-profile"
#   role = aws_iam_role.ec2.name
# }

# ── Frontend Launch Template ──────────────────────────────────────────────────
resource "aws_launch_template" "frontend" {
  name_prefix   = "${var.project}-${var.environment}-frontend-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  # iam_instance_profile { arn = aws_iam_instance_profile.ec2.arn }
  vpc_security_group_ids = [var.frontend_sg_id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project}-${var.environment}-frontend"
      Role        = "frontend"
      Environment = var.environment
      Project     = var.project
    }
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y python3 python3-pip
    pip3 install --user ansible
    pip3 install --user boto3 botocore
    # Ansible will handle the rest via playbook
  EOF
  )
}

# ── Frontend ASG ──────────────────────────────────────────────────────────────
resource "aws_autoscaling_group" "frontend" {
  name                = "${var.project}-${var.environment}-frontend-asg"
  vpc_zone_identifier = var.frontend_subnet_ids
  min_size            = 1 #var.frontend_min
  max_size            =  1 # var.frontend_max
  desired_capacity    = 1 #var.frontend_min
  target_group_arns   = [var.frontend_tg_arn]
  health_check_type   = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.frontend.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project}-${var.environment}-frontend"
    propagate_at_launch = true
  }
}

# ── Backend Launch Template ───────────────────────────────────────────────────
resource "aws_launch_template" "backend" {
  name_prefix   = "${var.project}-${var.environment}-backend-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  # iam_instance_profile { arn = aws_iam_instance_profile.ec2.arn }
  vpc_security_group_ids = [var.backend_sg_id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project}-${var.environment}-backend"
      Role        = "backend"
      Environment = var.environment
      Project     = var.project
    }
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y python3 python3-pip
    # Ansible will handle the rest via playbook
  EOF
  )
}

# ── Backend ASG ───────────────────────────────────────────────────────────────
resource "aws_autoscaling_group" "backend" {
  name                = "${var.project}-${var.environment}-backend-asg"
  vpc_zone_identifier = var.backend_subnet_ids
  min_size            = 1 #var.backend_min
  max_size            = 1 #var.backend_max
  desired_capacity    = 1 #var.backend_min
  target_group_arns   = [var.backend_tg_arn]
  health_check_type   = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project}-${var.environment}-backend"
    propagate_at_launch = true
  }
}
