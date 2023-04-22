data "template_file" "user_data" {
  template = file("${path.module}/template.sh")
  vars = {
    cluster_name    = var.cluster_name
    role_arn_to_assume = var.role_arn_to_assume
  }
}