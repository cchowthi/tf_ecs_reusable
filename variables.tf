variable "app_name" {
  description = "The name of the application"
}

variable "app_port" {
  description = "Port App Listens On"
  type        = string
}

variable "aws_account" {
  description = "AWS Account ID"
  type        = string
}

variable "cpu" {
  description = "CPU units for the task"
  type        = number
  default     = 512 # Default value set in reusable module
}

variable "memory" {
  description = "Memory in MiB for the task"
  type        = number
  default     = 1024 # Default value set in reusable module
}

variable "min" {
  description = "Minimum Number Of Containers"
  type        = string
}

variable "desired_count" {
  description = "Number of tasks to run"
  type        = number
  default     = 2
}

variable "env_vars" {
  type        = list(map(string))
  description = "ENV VARS for Docker"
}

variable "environment" {
  description = "The environment"
  type        = string
}

variable "image_url" {
  description = "The environment"
  type        = string
}

variable "region" {
  description = "The AWS region"
  type        = string
}

variable "user" {
  default     = "root"
  description = "ECS Docker User"
  type        = string
}

variable "alb_internal" {
  default     = true
  description = "Internal ALB true | false"
  type        = bool
}

variable "drop_invalid_header_fields" {
  default     = true
  description = "drop invalid header fields"
  type        = string
}

variable "health_check_path" {
  default     = "/"
  description = "health check path for the ALB"
  type        = string
}

variable "healthy_threshold" {
  default     = "2"
  description = "ALB Target Group Healthy Threshold"
  type        = string
}

variable "idle_timeout" {
  default     = "60"
  description = "ALB Idle Timeout"
  type        = string
}

variable "interval" {
  default     = "30"
  description = "ALB Target Group Interval"
  type        = string
}

variable "unhealthy_threshold" {
  default     = "4"
  description = "ALB Target Group Unhealthy Threshold"
  type        = string
}

variable "timeout" {
  default     = "10"
  description = "ALB Target Group Timeout"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private Subnet IDs"
  type        = list(string)
}