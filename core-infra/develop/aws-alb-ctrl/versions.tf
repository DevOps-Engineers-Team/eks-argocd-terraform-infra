terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.52.0"
    }
    spotinst = {
      source  = "spotinst/spotinst"
      version = ">= 1.14.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 1.2"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 2.1"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 1.11"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
  }
}
