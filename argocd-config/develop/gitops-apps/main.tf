module "argocd_config" {
  source           = "../../../modules/argocd-config"
  environment      = local.environment
  config_name    = local.config_name
  infra_alias = local.infra_alias

  cluster_name = local.cluster_name
  k8s_namespace= local.k8s_namespace
  eks_iam_role_arn = local.eks_iam_role_arn
  github_user_name = var.github_user_name
  apps_repo_name = var.apps_repo_name
  github_service_account_ssh_key = data.aws_ssm_parameter.github_service_account_ssh_key.value
  github_team = var.github_team

  argocd_apps_setup = local.argocd_apps_setup
}
