locals {
  environment   = basename(dirname(path.cwd))
  config_name = basename(dirname(dirname(path.cwd)))
  account_id = data.aws_caller_identity.current.account_id

  infra_alias = "core-infra"

  application  = "gitops"
  cluster_name = "${local.infra_alias}-${local.environment}-${local.application}-cluster"
  k8s_namespace = "${local.config_name}-${local.environment}"
  argocd_server_host = "argocd.witold-demo.com"

  argocd_apps_setup = {
    sonarqube = {
      path = "argocd/${local.environment}/sonarqube"
      git_revision = "main"
    }
    jenkins = {
      path = "argocd/${local.environment}/jenkins"
      git_revision = "main"
    }
    ingress = {
      path = "argocd/${local.environment}/alb-ingress"
      git_revision = "main"
    }
    tfenv = {
      path = "argocd/${local.environment}/tfenv-job"
      git_revision = "main"
    }
  }
  eks_iam_role_arn = "arn:aws:iam::${local.account_id}:role/EKS-Full-Access-Role"
}

variable "github_user_name" {
  default = "WitoldSlawko"
}

variable "apps_repo_name" {
  default = "DevOps-Engineers-Team/argocd-helm-charts"
}

variable "github_team" {
  default = "doet-admins"
}
