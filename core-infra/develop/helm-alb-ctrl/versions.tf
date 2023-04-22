terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.61.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.4.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.19.0"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
  }
  required_version = ">= 1.0.0"
}
