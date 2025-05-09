output "ecs_task_family" {
  value = aws_ecs_task_definition.app.family
}

output "ecs_task_revision" {
  value = aws_ecs_task_definition.app.revision
}