# Security Group for ECS
#tfsec:ignore:aws-ec2-no-public-ingress-sgr #tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group" "ecs_service" {
  vpc_id      = var.vpc_id
  name        = "${var.environment}-${var.app_name}-ecs-service-sg"
  description = "Allow egress from container"

  egress {
    description = "All Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "Inbound from ALB"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [var.inbound_sg_id]
  }

  ingress {
    description = "inbound from all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  tags = {
    Name        = "${var.environment}-${var.app_name}-ecs-service-sg"
    Environment = var.environment
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "fargate" {
  name = "${var.environment}-${var.app_name}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "${var.environment}-${var.app_name}-ecs-cluster"
    Environment = var.environment
  }
}

# Service for ECS
resource "aws_ecs_service" "app" {
  name            = "${var.environment}-${var.app_name}"
  task_definition = "${var.task_family}:${max("${var.task_revision}", "${var.task_revision}")}"
  desired_count   = var.min
  launch_type     = "FARGATE"
  cluster         = aws_ecs_cluster.fargate.id

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
  }

  network_configuration {
    security_groups = [aws_security_group.ecs_service.id]
    subnets         = flatten(var.private_subnet_ids)
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "${var.environment}-${var.app_name}"
    container_port   = var.app_port
  }

  # https://github.com/hashicorp/terraform/issues/12634
  depends_on = [var.alb_listener_arn]
}