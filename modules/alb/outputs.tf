output "alb_target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_alb_target_group.selected.arn
}

output "alb_listener_arn" {
  description = "ARN of the ALB HTTPS listener"
  value       = aws_alb_listener.https.arn
}

output "security_group_id" {
  description = "Security group ID for ALB"
  value       = aws_security_group.inbound_sg.id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_alb.selected.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_alb.selected.arn
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_alb.selected.zone_id
}