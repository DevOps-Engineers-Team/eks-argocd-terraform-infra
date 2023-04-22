module "helm_cert_manager" {
  source               = "../../../modules/generic-helm-release"
  environment          = local.environment
  helm_repo_url        = var.helm_repo_url
  kubernetes_namespace = var.kubernetes_namespace
  create_namespace = var.create_namespace
  helm_chart_name      = var.helm_chart_name
  helm_chart_version   = var.helm_chart_version
  helm_sets = var.helm_sets
}
