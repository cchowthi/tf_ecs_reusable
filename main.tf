module "alb" {
  source                     = "./modules/alb"
  alb_internal               = var.alb_internal
  app_name                   = var.app_name
  app_port                   = var.app_port
  drop_invalid_header_fields = var.drop_invalid_header_fields
  environment                = var.environment
  health_check_path          = var.health_check_path
  healthy_threshold          = var.healthy_threshold
  idle_timeout               = var.idle_timeout
  interval                   = var.interval
  private_subnet_ids         = var.private_subnet_ids
  timeout                    = var.timeout
  unhealthy_threshold        = var.unhealthy_threshold
  vpc_id                     = var.vpc_id
}

module "ecr" {
  source           = "./modules/ecr"
  ecr_repo_name    = var.ecr_repo_name
  image_mutability = var.image_mutability
  encrypt_type     = var.encrypt_type
  tags = {
    "Environment" = var.environment
  }
}

module "docker" {
  source              = "./modules/docker"
  aws_account         = var.aws_account
  docker_path         = var.docker_path
  relative_path       = var.relative_path
  ecr_repo_name       = var.ecr_repo_name
  force_image_rebuild = var.force_image_rebuild
  region              = var.region
}

module "ecs_task" {
  source      = "./modules/ecs-task"
  app_name    = var.app_name
  app_port    = var.app_port
  bucket_name = var.bucket_name
  aws_account = var.aws_account
  task_cpu    = var.task_cpu
  ecr_repo    = var.ecr_repo_name
  env_vars    = var.env_vars
  environment = var.environment
  image_url   = module.docker.image_uri
  task_memory = var.taskmemory
  region      = var.region
  user        = var.user
}

module "ecs_service" {
  source             = "./modules/ecs-service"
  alb_listener_arn   = module.alb.alb_listener_arn
  app_name           = var.app_name
  app_port           = var.app_port
  desired_count      = var.desired_count
  environment        = var.environment
  image_url          = module.docker.image_uri
  inbound_sg_id      = module.alb.security_group_id
  min                = var.min
  private_subnet_ids = var.private_subnet_ids
  region             = var.region
  target_group_arn   = module.alb.alb_arget_group_arn
  task_family        = module.ecs_task.ecs_task_family
  task_revision      = module.ecs_task.ecs_task_revision
  user               = var.user
  vpc_id             = var.vpc_id
}
