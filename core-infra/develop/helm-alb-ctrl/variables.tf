locals {
  environment   = basename(dirname(path.cwd))
  config_name = basename(dirname(dirname(path.cwd)))
  application  = "gitops"
  cluster_name = "${local.config_name}-${local.environment}-${local.application}-cluster"

  helm_sets = {
    clusterName = {
        name  = "clusterName"
        value = local.cluster_name
        type  = "string"
      }
  }
}

variable "app_name" {
  default = "alb-ctrl"
}

variable "helm_repo_url" {
  default = "https://aws.github.io/eks-charts"
}

variable "kubernetes_namespace" {
  default = "alb-ctrl"
}

variable "create_namespace" {
  type = bool
  default = true
}

variable "helm_chart_name" {
  default = "aws-load-balancer-controller"
}

variable "helm_chart_version" {
  default = "1.4.8"
}

variable "helm_sets" {
  default = {}
}

variable "image_version" {
  default = "2.4.7"
}

variable "target_domain" {
  default = "witold-demo.com"
}
