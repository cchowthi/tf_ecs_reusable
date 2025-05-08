# Task definition for the app service
data "template_file" "app" {
  template = file("${path.module}/app_task_definition.json")

  vars = {
    env_vars      = jsonencode(var.env_vars)
    app_name      = "${var.environment}-${var.app_name}"
    memory        = var.memory
    image         = var.image_url
    region        = var.region
    port          = var.app_port
    awslogs-group = "${var.environment}_fargate_ecs"
    user          = var.user


  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.environment}-${var.app_name}"
  container_definitions    = data.template_file.app.rendered
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = data.aws_iam_role.ecs_execution_role.arn
  task_role_arn            = data.aws_iam_role.ecs_execution_role.arn
}

# Security Group for ECS
#tfsec:ignore:aws-ec2-no-public-ingress-sgr #tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group" "ecs_service" {
  vpc_id      = data.aws_vpc.selected.id
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
    security_groups = [aws_security_group.inbound_sg.id]
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

# Service for ECS
resource "aws_ecs_service" "app" {
  name            = "${var.environment}-${var.app_name}"
  task_definition = "${aws_ecs_task_definition.app.family}:${max("${aws_ecs_task_definition.app.revision}", "${data.aws_ecs_task_definition.app.revision}")}"
  desired_count   = var.min
  launch_type     = "FARGATE"
  cluster         = data.aws_ecs_cluster.fargate.id

  network_configuration {
    security_groups = [aws_security_group.ecs_service.id]
    subnets         = flatten([data.aws_subnet.private[*].id])
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.selected.arn
    container_name   = "${var.environment}-${var.app_name}"
    container_port   = var.app_port
  }

  # https://github.com/hashicorp/terraform/issues/12634
  depends_on = [aws_alb_listener.selected]

  service_registries {
    registry_arn   = aws_service_discovery_service.terraform.arn
    container_name = "${var.environment}-${var.app_name}"
  }
}