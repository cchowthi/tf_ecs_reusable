# Task definition for the app service
data "template_file" "app" {
  template = file("${path.module}/dash_task_definition.json")

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

# ECS Execution Role
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.environment}-${var.app_name}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-${var.app_name}-ecs-execution-role"
    Environment = var.environment
  }
}

# ECS Execution Role Policy
resource "aws_iam_role_policy" "ecs_execution_policy" {
  name = "${var.environment}-${var.app_name}-ecs-execution-policy"
  role = aws_iam_role.ecs_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = [
          "arn:aws:ecr:${var.region}:${var.aws_account}:repository/${var.ecr_repo}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = ["*"]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:${var.region}:${var.aws_account}:log-group:${var.environment}_fargate_ecs:*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:GetObjectVersion",
          "s3:GetObjectACL",
          "s3:PutObjectACL"
        ],
        "Resource" : "arn:aws:s3:::${var.bucket_name}/*"
      },
    ]
  })
}

resource "aws_ecs_task_definition" "app" {
  family = "${var.environment}-${var.app_name}"
  container_definitions = jsonencode([
    {
      "name" : "${var.environment}-${var.app_name}",
      "image" : var.image_url,
      "portMappings" : [
        {
          "containerPort" : var.app_port,
          "hostPort" : var.app_port,
          "appProtocol" : "http"
        }
      ],
      "memory" : var.memory,
      "networkMode" : "awsvpc",
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "${var.environment}_fargate_ecs",
          "awslogs-region" : var.region,
          "awslogs-create-group" : "true",
          "awslogs-stream-prefix" : "${var.environment}-${var.app_name}"
        }
      },
      "environment" : [
        for k, v in var.env_vars : {
          "name" : tostring(k),
          "value" : tostring(v)
        }
      ]
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_execution_role.arn
}