terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.4.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.19.0"
    }
  }
  required_version = ">= 1.0.0"
}
