locals {
  helm_settings = {
    "server.service.type" =  "LoadBalancer"
    "server.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"         = data.aws_acm_certificate.cert.arn
  }
}

variable "cluster_name" {}

variable "environment" {}

variable "config_name" {}

variable "account_id" {}

variable "target_domain" {}

variable "helm_repo_url" {
  type        = string
  default     = "https://argoproj.github.io/argo-helm"
  description = "Helm repository"
}

variable "kubernetes_argocd_namespace" {
  description = "Namespace to release argocd into"
  type        = string
  default     = "argocd"
}

variable "argocd_helm_chart_version" {
  description = "argocd helm chart version to use"
  type        = string
  default     = ""
}

variable "argocd_server_host" {
  description = "Hostname for argocd (will be utilised in ingress if enabled)"
  type        = string
}

variable "argocd_ingress_class" {
  description = "Ingress class to use for argocd"
  type        = string
  default     = "nginx"
}

variable "argocd_ingress_enabled" {
  description = "Enable/disable argocd ingress"
  type        = bool
  default     = true
}

variable "argocd_ingress_tls_acme_enabled" {
  description = "Enable/disable acme TLS for ingress"
  type        = string
  default     = "true"
}

variable "argocd_ingress_ssl_passthrough_enabled" {
  description = "Enable/disable SSL passthrough for ingresss"
  type        = string
  default     = "true"
}

variable "argocd_ingress_tls_secret_name" {
  description = "Secret name for argocd TLS cert"
  type        = string
  default     = "argocd-cert"
}

variable "eks_iam_argocd_role_name" {
  description = "IAM EKS service account role name for Argo CD"
  type        = string
}

variable "argocd_github_client_id" {
  description = "GitHub OAuth application client id (see Argo CD user management guide)"
  type        = string
}

variable "argocd_github_client_secret" {
  description = "GitHub OAuth application client secret (see Argo CD user management guide)"
  type        = string
}

variable "argocd_github_org_name" {
  description = "Organisation to restrict Argo CD to"
  type        = string
}

variable "github_team" {}

variable "argocd_project_name" {}
