locals {
  environment   = var.environment
  config_name = var.config_name
  account_id    = var.account_id
  
  aws_alb_ingress_controller_docker_image = "docker.io/amazon/aws-alb-ingress-controller:v${var.aws_alb_ingress_controller_version}"
  aws_alb_ingress_controller_version      = var.aws_alb_ingress_controller_version
  aws_alb_ingress_class                   = "alb"
  aws_vpc_id                              = data.aws_vpc.selected.id
  aws_region_name                         = data.aws_region.current.name
  aws_iam_path_prefix                     = var.aws_iam_path_prefix == "" ? null : var.aws_iam_path_prefix
  k8s_cluster_name = var.cluster_name
  cluster_oidc_issuer_url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  oidc_host_path = split("://", local.cluster_oidc_issuer_url)[1]
}

variable "cluster_name" {}

variable "environment" {}

variable "config_name" {}

variable "account_id" {}

variable "k8s_cluster_type" {
  description = "Can be set to `vanilla` or `eks`. If set to `eks`, the Kubernetes cluster will be assumed to be run on EKS which will make sure that the AWS IAM Service integration works as supposed to."
  type        = string
  default     = "eks"
}

variable "k8s_namespace" {
  description = "Kubernetes namespace to deploy the AWS ALB Ingress Controller into."
  type        = string
  default     = "default"
}

variable "k8s_replicas" {
  description = "Amount of replicas to be created."
  type        = number
  default     = 1
}

variable "k8s_pod_annotations" {
  description = "Additional annotations to be added to the Pods."
  type        = map(string)
  default     = {}
}

variable "k8s_pod_labels" {
  description = "Additional labels to be added to the Pods."
  type        = map(string)
  default     = {}
}

variable "aws_iam_path_prefix" {
  description = "Prefix to be used for all AWS IAM objects."
  type        = string
  default     = ""
}

variable "aws_vpc_id" {
  description = "ID of the Virtual Private Network to utilize. Can be ommited if targeting EKS."
  type        = string
  default     = null
}

variable "aws_region_name" {
  description = "ID of the Virtual Private Network to utilize. Can be ommited if targeting EKS."
  type        = string
  default     = null
}

variable "aws_resource_name_prefix" {
  description = "A string to prefix any AWS resources created. This does not apply to K8s resources"
  type        = string
  default     = "k8s-"
}

variable "aws_tags" {
  description = "Common AWS tags to be applied to all AWS objects being created."
  type        = map(string)
  default     = {}
}

variable "aws_alb_ingress_controller_version" {
  description = "The AWS ALB Ingress Controller version to use. See https://github.com/kubernetes-sigs/aws-alb-ingress-controller/releases for available versions"
  type        = string
  default     =  "2.4.1"
}
