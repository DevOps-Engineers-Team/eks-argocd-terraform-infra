data "aws_eks_cluster" "cluster" {
  name = local.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = local.cluster_name
}

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "argocd_oauth_client_id" {
  name = "/secrets/${local.infra_alias}/${local.environment}/argocd_oauth_client_id"
}

data "aws_ssm_parameter" "argocd_oauth_client_secret" {
  name = "/secrets/${local.infra_alias}/${local.environment}/argocd_oauth_client_secret"
}

data "aws_ssm_parameter" "argocd_auth_token" {
  name = "/secrets/${local.infra_alias}/${local.environment}/argocd_auth_token"
}

data "aws_ssm_parameter" "github_service_account_ssh_key" {
  name = "/secrets/github_service_account_ssh_key"
}
