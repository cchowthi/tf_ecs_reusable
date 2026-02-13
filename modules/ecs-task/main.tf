
locals {
  container_definitions = jsonencode([
    {
      name      = "${var.environment}-${var.app_name}"
      app_name  = "${var.environment}-${var.app_name}"
      image     = var.image_url
      cpu       = var.cpu
      memory    = var.memory
      essential = true
      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
        }
      ]
      command = [
        "-Dsonar.search.javaAdditionalOpts=-Dnode.store.allow_mmap=false"
      ]
      environment = var.env_vars
      linuxParameters = {
        "initProcessEnabled" : true
      }
      ulimits = [
        {
          "name" : "nofile",
          "softLimit" : 65535,
          "hardLimit" : 65535
        }
      ]
      logConfiguration = {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : "${var.environment}_fargate_ecs",
          "awslogs-region" : "${var.region}",
          "awslogs-stream-prefix" : "${var.environment}-sonarqube"
        }
      }
    },
    # TwistlockDefender sidecar container
    {
      name      = "TwistlockDefender"
      image     = "registry-auth.twistlock.com/tw_mfxrfydek289ufo4ch0qs5avbn4xr5ga/twistlock/defender:defender_34_03_138"
      cpu       = 4096
      memory    = 16384
      essential = false
      entryPoint = [
        "/usr/local/bin/defender",
        "fargate",
        "sidecar"
      ]
      environment = [
        { name = "INSTALL_BUNDLE", value = "eyJzZWNyZXRzIjp7InNlcnZpY2UtcGFyYW1ldGVyIjoiY2xEWVR4UDErcUp3VVhsZDVhZldqa3JyM3g2ZitSZFBKdFZtN21JVXVQNHNvemFxN0FEcTVKYk1FUWNCQTRwaGovODA5OU9HU1RQVGw5dUVBcDk5Rmc9PSJ9LCJnbG9iYWxQcm94eU9wdCI6eyJodHRwUHJveHkiOiIiLCJub1Byb3h5IjoiIiwiY2EiOiIiLCJ1c2VyIjoiIiwicGFzc3dvcmQiOnsiZW5jcnlwdGVkIjoiIn19LCJjdXN0b21lcklEIjoidXMtMy0xNTkyNjY4MDMiLCJhcGlLZXkiOiJFZ1FjLzZQWFVtbEdHTGFUY05NeXQxdGphVnBFT2NUcWJBVVlqZkRmNXNQaWRWT0RBa2JSWlkrRU5ZSGxVZXNUMENJa1QrdzhIdWZqRjd4MUp6VUViZz09IiwibWljcm9zZWdDb21wYXRpYmxlIjpmYWxzZX0=" },
        { name = "DEFENDER_TYPE", value = "fargate" },
        { name = "FARGATE_TASK", value = "${var.environment}-${var.app_name}" },
        { name = "WS_ADDRESS", value = "wss://us-west1.cloud.twistlock.com:443" },
        { name = "FILESYSTEM_MONITORING", value = "false" },
        { name = "FIPS_ENABLED", value = "false" },
        { name = "DEBUG", value = "true" }
      ]
      healthCheck = {
        command     = ["/usr/local/bin/defender", "fargate", "healthcheck"]
        interval    = 5
        retries     = 3
        startPeriod = 1
        timeout     = 5
      }
      logConfiguration = {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : "${var.environment}_fargate_ecs",
          "awslogs-region" : "${var.region}",
          "awslogs-stream-prefix" : "${var.environment}-sonarqube"
        }
      }
      portMappings = []
      mountPoints = [
        {
          sourceVolume  = "service-storage"
          containerPath = "/data"
          readOnly      = false
        }
      ]
    }
  ])
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
  family                   = "${var.environment}-${var.app_name}"
  container_definitions    = local.container_definitions
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_execution_role.arn
  tags = {
    Name        = "${var.environment}-${var.app_name}-ecs-task"
    Environment = var.environment
  }
}