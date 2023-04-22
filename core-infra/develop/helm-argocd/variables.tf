locals {
  environment   = basename(dirname(path.cwd))
  config_name = basename(dirname(dirname(path.cwd)))
  account_id    = data.aws_caller_identity.current.account_id
  
  application  = "gitops"
  cluster_name = "${local.config_name}-${local.environment}-${local.application}-cluster"
  k8s_namespace = "${local.config_name}-${local.environment}"

  argocd_server_host = "argocd.${local.target_domain}"
  argocd_project_name = "argocd-config-${local.environment}-argocd-project"

  target_domain = "witold-demo.com"
}

variable "argocd_helm_chart_version" {
  default = "3.32.1"
}

variable "argocd_github_org_name" {
  default = "DevOps-Engineers-Team"
}

variable "eks_iam_argocd_role_name" {
  default = "EKS-Full-Access-Role"
}

variable "github_team" {
  default = "doet-admins"
}
