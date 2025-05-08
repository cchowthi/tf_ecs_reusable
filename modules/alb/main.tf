resource "random_id" "target_group_sufix" {
  byte_length = 2
}

resource "aws_alb_target_group" "selected" {
  name        = "${var.environment}-${var.app_name}-alb-${random_id.target_group_sufix.hex}"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    timeout             = var.timeout
    interval            = var.interval
    path                = var.health_check_path
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Security group for ALB
#tfsec:ignore:aws-ec2-no-public-ingress-sgr #tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group" "inbound_sg" {
  name        = "${var.environment}-${var.app_name}-inbound-sg"
  description = "Allow HTTP from Anywhere into ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Inbound from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "inbound icmp from anywhere"
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "outbound to anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-${var.app_name}-inbound-sg"
  }
}

resource "aws_alb" "selected" {
  name                       = "${var.environment}-${var.app_name}-alb"
  internal                   = var.alb_internal
  drop_invalid_header_fields = var.drop_invalid_header_fields
  subnets                    = var.private_subnet_ids
  security_groups            = [aws_security_group.inbound_sg.id]
  idle_timeout               = var.idle_timeout

  tags = {
    Name        = "${var.environment}-${var.app_name}-alb"
    Environment = var.environment
  }
}
#tfsec:ignore:aws-elb-http-not-used
resource "aws_alb_listener" "selected" {
  load_balancer_arn = aws_alb.selected.arn
  port              = "80"
  protocol          = "HTTP"
  depends_on        = [aws_alb_target_group.selected]

  default_action {
    target_group_arn = aws_alb_target_group.selected.arn
    type             = "forward"
  }
}