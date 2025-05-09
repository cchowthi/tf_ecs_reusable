output "alb_arget_group_arn" {
  value = aws_alb_target_group.selected.arn
}

output "alb_listener_arn" {
  value = aws_alb_listener.selected.arn
}

output "security_group_id" {
  value = aws_security_group.inbound_sg.id
}