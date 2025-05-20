locals {

  ecr_reg   = "${var.aws_account}.dkr.ecr.${var.region}.amazonaws.com" # ECR docker registry URI
  image_uri = "${local.ecr_reg}/${var.ecr_repo_name}:latest"
  ecr_repo  = var.ecr_repo_name


  dkr_img_src_path = "${path.module}/${var.relative_path}${var.docker_path}"

  all_files = [
    for f in sort(fileset(local.dkr_img_src_path, "**")) :
    f
  ]

  dkr_img_src_sha256 = sha256(join("", [
    for f in sort(fileset(local.dkr_img_src_path, "*")) :
    filesha256("${local.dkr_img_src_path}${f}") if strcontains(f, "Dockerfile") || strcontains(f, "assets") || endswith(f, ".py") || endswith(f, ".txt") || endswith(f, ".properties")
  ]))

  dkr_build_cmd = <<EOT
find ${local.dkr_img_src_path} -name "*.py" -exec chmod 744 {} \; && \
find ${local.dkr_img_src_path} -name "*.properties" -exec chmod 744 {} \; && \
docker build --platform=linux/amd64 -t ${local.ecr_reg}/${local.ecr_repo}:latest \
    -f ${local.dkr_img_src_path}Dockerfile_app ${local.dkr_img_src_path} && \
aws ecr get-login-password --region ${var.region} | \
    docker login --username AWS --password-stdin ${local.ecr_reg} && \
docker push ${local.ecr_reg}/${local.ecr_repo}:latest
EOT

}

resource "null_resource" "debug_included_files" {
  provisioner "local-exec" {
    command = <<EOT
echo "Included files for hash:"
echo ${join(" ", local.all_files)}
EOT
  }
}

# local-exec for build and push of docker image
resource "null_resource" "build_push_dkr_img" {
  triggers = {
    detect_docker_source_changes = var.force_image_rebuild == true ? timestamp() : local.dkr_img_src_sha256
  }
  provisioner "local-exec" {
    command = local.dkr_build_cmd
  }

}

output "trigged_by" {
  value = null_resource.build_push_dkr_img.triggers
}