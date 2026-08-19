output "ecs_task_family" {
  description = "ECS task definition family"
  value       = aws_ecs_task_definition.app.family
}

output "ecs_task_revision" {
  description = "ECS task definition revision"
  value       = aws_ecs_task_definition.app.revision
}

output "ecs_task_arn" {
  description = "Full ARN of the ECS task definition"
  value       = aws_ecs_task_definition.app.arn
}

output "execution_role_arn" {
  description = "ARN of the ECS execution role"
  value       = aws_iam_role.ecs_execution_role.arn
}

output "execution_role_name" {
  description = "Name of the ECS execution role"
  value       = aws_iam_role.ecs_execution_role.name
}