module "argocd_helm_custom" {
  source           = "../../../modules/argocd-helm-release"
  environment      = local.environment
  config_name    = local.config_name
  account_id    = local.account_id
  cluster_name = local.cluster_name

  target_domain = local.target_domain

  argocd_server_host = local.argocd_server_host
  argocd_helm_chart_version = var.argocd_helm_chart_version
  argocd_github_org_name = var.argocd_github_org_name
  eks_iam_argocd_role_name = var.eks_iam_argocd_role_name

  argocd_github_client_id = data.aws_ssm_parameter.argocd_oauth_client_id.value
  argocd_github_client_secret = data.aws_ssm_parameter.argocd_oauth_client_secret.value

  argocd_project_name = local.argocd_project_name
  github_team = var.github_team
}
