variable "cluster_name" {}

variable "environment" {}

variable "config_name" {}

variable "infra_alias" {}

variable "k8s_namespace" {}

variable "eks_iam_role_arn" {}

variable "github_user_name" {}

variable "apps_repo_name" {}

variable "github_service_account_ssh_key" {}

variable "argocd_apps_setup" {
  type = map(map(string))
  # default = {
  #     # config_name = path
  # }
}

variable "github_team" {}
