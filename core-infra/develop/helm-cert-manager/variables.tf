locals {
  environment   = basename(dirname(path.cwd))
  config_name = basename(dirname(dirname(path.cwd)))
  application  = "gitops"
  cluster_name = "${local.config_name}-${local.environment}-${local.application}-cluster"
}

variable "helm_repo_url" {
  default = "https://charts.jetstack.io"
}

variable "helm_chart_name" {
  default = "cert-manager"
}

variable "helm_chart_version" {
  default = "1.9.1" # "1.8.2"
}

variable "kubernetes_namespace" {
  default = "cert-manager"
}

variable "create_namespace" {
  type = bool
  default = true
}

variable "helm_sets" {
  default = {
    crds = {
      name  = "installCRDs"
      value = true
      type  = "auto"
    }
  }
}

variable "cm_images_version" {
  default = "1.8.2"
}

