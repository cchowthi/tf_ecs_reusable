
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
      mountPoints = [
        {
          "sourceVolume" : "service-storage",
          "containerPath" : var.container_path,
          "readOnly" : false
        }
      ]
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
      image     = var.twistlock_defender_image
      cpu       = var.twistlock_cpu
      memory    = var.twistlock_memory
      essential = false
      entryPoint = [
        "/usr/local/bin/defender",
        "fargate",
        "sidecar"
      ]
      environment = [
        { name = "INSTALL_BUNDLE", value = var.twistlock_install_bundle },
        { name = "DEFENDER_TYPE", value = "fargate" },
        { name = "FARGATE_TASK", value = "${var.environment}-${var.app_name}" },
        { name = "WS_ADDRESS", value = var.twistlock_ws_address },
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

  volume {
    name = "service-storage"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.service-storage.id
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
      authorization_config {
        access_point_id = aws_efs_access_point.service-storage.id
        iam             = "ENABLED"
      }
    }
  }

  tags = local.common_tags
}