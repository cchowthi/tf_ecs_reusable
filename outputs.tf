# ECS Service outputs
output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs_service.cluster_name
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs_service.cluster_arn
}

output "service_name" {
  description = "Name of the ECS service"
  value       = module.ecs_service.service_name
}

output "service_arn" {
  description = "ARN of the ECS service"
  value       = module.ecs_service.service_arn
}

output "ecs_security_group_id" {
  description = "Security group ID for ECS tasks"
  value       = module.ecs_service.ecs_security_group_id
}

# ECS Task outputs
output "ecs_task_family" {
  description = "ECS task definition family"
  value       = module.ecs_task.ecs_task_family
}

output "ecs_task_revision" {
  description = "ECS task definition revision"
  value       = module.ecs_task.ecs_task_revision
}

output "execution_role_arn" {
  description = "ARN of the ECS execution role"
  value       = module.ecs_task.execution_role_arn
}

output "task_role_arn" {
  description = "ARN of the ECS task role"
  value       = module.ecs_task.execution_role_arn # Using same role for both
}

# ALB outputs
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_alb.selected.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_alb.selected.arn
}

output "alb_listener_arn" {
  description = "ARN of the ALB HTTPS listener"
  value       = module.alb.alb_listener_arn
}

output "alb_target_group_arn" {
  description = "ARN of the ALB target group"
  value       = module.alb.alb_target_group_arn
}

output "alb_security_group_id" {
  description = "Security group ID for the ALB"
  value       = module.alb.security_group_id
}

# ECR/Docker outputs
output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.docker.ecr_reg
}

output "docker_image_uri" {
  description = "Full URI of the Docker image"
  value       = module.docker.image_uri
}

output "docker_image_sha" {
  description = "SHA256 digest of the Docker image"
  value       = module.docker.image_sha
}