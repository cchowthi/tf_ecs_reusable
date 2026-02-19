variable "app_name" {
  description = "The name of the application"
}

variable "app_port" {
  description = "Port App Listens On"
  type        = number
}

variable "aws_account" {
  description = "AWS Account ID"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "cpu" {
  description = "CPU units for the app"
  type        = number
  default     = 4096 # Default value set in reusable module
}

variable "task_cpu" {
  description = "CPU units for the task"
  type        = number
  default     = 8192 # Must be >= sum of all container CPU (4096 + 4096 for TwistlockDefender)
}

variable "memory" {
  description = "Memory in MiB for the app"
  type        = number
  default     = 16384 # Default value set in reusable module
}

variable "task_memory" {
  description = "Memory in MiB for the task"
  type        = number
  default     = 30720 # Must be >= sum of all container memory (16384 + 16384 for TwistlockDefender = 32768, using 30720 as valid Fargate value)
}

variable "min" {
  description = "Minimum Number Of Containers"
  type        = string
  default     = "1"
}

variable "desired_count" {
  description = "Number of tasks to run"
  type        = number
  default     = 2
}

variable "encrypt_type" {
  description = "Provide type of encryption here"
  type        = string
  default     = "KMS"
}

variable "image_mutability" {
  description = "Provide image mutability"
  type        = string
  default     = "MUTABLE"
}

variable "relative_path" {
  description = "Relative path to the source directory"
  type        = string
  default     = "../../../../../../"
}

variable "docker_path" {
  description = "Path to the Dockerfile and app files"
  type        = string
}
variable "ecr_repo_name" {
  description = "The environment"
  type        = string
}

variable "env_vars" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "ENV VARS for Docker"
}


variable "environment" {
  description = "The environment"
  type        = string
}

variable "force_image_rebuild" {
  type    = bool
  default = false
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
  default     = "120"
  description = "ALB Idle Timeout"
  type        = string
}

variable "interval" {
  default     = "60"
  description = "ALB Target Group Interval"
  type        = string
}

variable "unhealthy_threshold" {
  default     = "4"
  description = "ALB Target Group Unhealthy Threshold"
  type        = string
}

variable "timeout" {
  default     = "30"
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