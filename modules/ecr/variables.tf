variable "ecr_repo_name" {
  description = "The environment"
  type        = string
}

variable "image_mutability" {
  description = "Provide image mutability"
  type        = string
}

variable "encrypt_type" {
  description = "Provide type of encryption here"
  type        = string
}

variable "tags" {
  description = "Tags for the ECR repository"
  type        = map(string)
  default     = {}
}
