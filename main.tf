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

module "ecs_task" {
  source      = "./modules/ecs-task"
  app_name    = var.app_name
  app_port    = var.app_port
  cpu         = var.cpu
  env_vars    = var.env_vars
  environment = var.environment
  image_url   = var.image_url
  memory      = var.memory
  region      = var.region
  user        = var.user
}

module "ecs_service" {
  source             = "./modules/ecs-service"
  alb_listener_arn   = module.alb.alb_listener_arn
  app_name           = var.app_name
  app_port           = var.app_port
  container_image    = var.image_url
  desired_count      = var.desired_count
  environment        = var.environment
  image_url          = var.image_url
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
