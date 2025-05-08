variable "app_name" {
  description = "The name of the application"
}

variable "container_image" {
  description = "The Docker image for the app"
  type        = string
}

variable "cpu" {
  description = "CPU units for the task"
  type        = number
  default     = 512  # Default value set in reusable module
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

variable "app_port" {
  description = "Port App Listens On"
  type        = string
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