variable "aws_account" {
  description = "AWS Account ID"
  type        = string
}

variable "docker_path" {
  description = "Path to the Dockerfile and app files"
  type        = string
}

variable "relative_path" {
  description = "Relative path to the source directory"
  type        = string
}

variable "ecr_repo_name" {
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