variable "app_name" {
  description = "The name of the application"
}

variable "app_port" {
  description = "Port App Listens On"
  type        = string
}

variable "cpu" {
  description = "CPU units for the task"
  type        = number
  default     = 512 # Default value set in reusable module
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

variable "memory" {
  description = "Memory in MiB for the task"
  type        = number
  default     = 1024 # Default value set in reusable module
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