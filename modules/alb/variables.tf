variable "alb_internal" {
  default     = true
  description = "Internal ALB true | false"
  type        = bool
}

variable "app_name" {
  description = "The name of the application"
}

variable "app_port" {
  description = "Port App Listens On"
  type        = string
}

variable "drop_invalid_header_fields" {
  default     = true
  description = "drop invalid header fields"
  type        = string
}

variable "environment" {
  description = "The environment"
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