variable "alb_listener_arn" {
  description = "The ARN of the ALB listener"
}

variable "app_name" {
  description = "The name of the application"
}

variable "app_port" {
  description = "Port App Listens On"
  type        = string
}

variable "container_image" {
  description = "The Docker image for the app"
  type        = string
}

variable "desired_count" {
  description = "Number of tasks to run"
  type        = number
  default     = 2
}

variable "environment" {
  description = "The environment"
  type        = string
}

variable "image_url" {
  description = "The environment"
  type        = string
}

variable "inbound_sg_id" {
  description = "The security group ID for inbound traffic"
  type        = string
}

variable "min" {
  description = "Minimum Number Of Containers"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private Subnet IDs"
  type        = list(string)
}

variable "region" {
  description = "The AWS region"
  type        = string
}

variable "target_group_arn" {
  description = "The ARN of the target group"
  type        = string
}

variable "task_family" {
  description = "The family of the task definition"
  type        = string
}

variable "task_revision" {
  description = "The task revision"
  type        = string
}

variable "user" {
  default     = "root"
  description = "ECS Docker User"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}