data "aws_eks_cluster" "cluster" {
  name = local.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = local.cluster_name
}

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "argocd_oauth_client_id" {
  name = "/secrets/${local.config_name}/${local.environment}/argocd_oauth_client_id"
}

data "aws_ssm_parameter" "argocd_oauth_client_secret" {
  name = "/secrets/${local.config_name}/${local.environment}/argocd_oauth_client_secret"
}
