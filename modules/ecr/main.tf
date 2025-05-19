#tfsec:ignore:aws-ecr-repository-customer-key
resource "aws_ecr_repository" "ecr_repo" {
  name                 = var.ecr_repo_name
  image_tag_mutability = var.image_mutability
  encryption_configuration {
    encryption_type = var.encrypt_type
  }
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "KMS"
  }
  tags = var.tags
  lifecycle {
    ignore_changes = all
  }
}