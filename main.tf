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
}
