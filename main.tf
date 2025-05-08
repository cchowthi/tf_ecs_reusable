module "alb" {
  source                     = "./modules/alb"
  app_name                   = var.app_name
  environment                = var.environment
  alb_internal               = var.alb_internal
  app_port                   = var.app_port
  drop_invalid_header_fields = var.drop_invalid_header_fields
  health_check_path          = var.health_check_path
  healthy_threshold          = var.healthy_threshold
  idle_timeout               = var.idle_timeout
  interval                   = var.interval
  unhealthy_threshold        = var.unhealthy_threshold
  timeout                    = var.timeout
  vpc_id                     = var.vpc_id
}

module "ecs_service" {
  source          = "./modules/ecs-service"
  app_name        = var.app_name
  container_image = var.image_url
  cpu             = var.cpu
  memory          = var.memory
  min             = var.min
  desired_count   = var.desired_count
  app_port        = var.app_port
  env_vars        = var.env_vars
  environment     = var.environment
  image_url       = var.image_url
  region          = var.region
  user            = var.user
  inbound_sg_id   = module.alb.security_group_id
  vpc_id          = var.vpc_id
}