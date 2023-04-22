locals {
  environment   = basename(dirname(path.cwd))
  config_name = basename(dirname(dirname(path.cwd)))
}

variable "repo_list" {
  type = list(string)
  default = ["repo:DevOps-Engineers-Team/eks-argocd-terraform-infra:*"]
}
