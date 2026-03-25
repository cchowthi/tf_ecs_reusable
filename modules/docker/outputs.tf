output "ecr_reg" {
  value = local.ecr_reg
}

output "image_uri" {
  value = local.image_uri
}

output "image_sha" {
  value = local.dkr_img_src_sha256
}