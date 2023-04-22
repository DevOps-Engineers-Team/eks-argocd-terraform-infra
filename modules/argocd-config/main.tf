resource "kubernetes_namespace" "ns" {
  count = var.k8s_namespace != "default" ? 1 : 0
  metadata {
    name = var.k8s_namespace
  }
}

resource "argocd_cluster" "eks_cluster" {
  depends_on = [kubernetes_namespace.ns]
  server     = data.aws_eks_cluster.cluster.endpoint
  name       = "eks_cluster"
  namespaces = ["default", "argocd", var.k8s_namespace]

  config {
    tls_client_config {
      ca_data = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    }
  }
}

resource "argocd_project" "argocd_project" {
  depends_on = [argocd_cluster.eks_cluster]
  metadata {
    name      = "${var.config_name}-${var.environment}-argocd-project"
    namespace = "argocd"
    labels = {
      acceptance = "true"
    }
  }

  spec {
    description  = "Demo ArgoCD setup"
    source_repos = ["*"]

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = var.k8s_namespace
    }

    cluster_resource_whitelist {
      group = "*"
      kind  = "*"
    }

    namespace_resource_whitelist {
      group = "*"
      kind  = "*"
    }
    orphaned_resources {
      warn = false

    }
    role {
      name = "argocd-${var.config_name}-${var.environment}-application-controller"
      policies = [
        "p, proj:${var.config_name}-${var.environment}-argocd-project:argocd-${var.config_name}-${var.environment}-application-controller, applications, override, ${var.config_name}-${var.environment}-argocd-project/*, allow",
        "p, proj:${var.config_name}-${var.environment}-argocd-project:argocd-${var.config_name}-${var.environment}-application-controller, applications, sync, ${var.config_name}-${var.environment}-argocd-project/*, allow",
      ]
    }
    role {
      name = "argocd-${var.config_name}-${var.environment}-dex-server"
      policies = [
        "p, proj:${var.config_name}-${var.environment}-argocd-project:argocd-${var.config_name}-${var.environment}-dex-server, applications, get, ${var.config_name}-${var.environment}-argocd-project/*, allow",
        "p, proj:${var.config_name}-${var.environment}-argocd-project:argocd-${var.config_name}-${var.environment}-dex-server, applications, sync, ${var.config_name}-${var.environment}-argocd-project/*, allow",
      ]
      groups = ["*"]
    }
    sync_window {
      kind         = "allow"
      applications = ["*"]
      clusters     = ["*"]
      namespaces   = ["*"]
      duration     = "3600s"
      schedule     = "3 * * * *"
      manual_sync  = true
    }
  }
}

resource "argocd_project_token" "argocd_secret" {
  depends_on = [argocd_project.argocd_project]
  project      = "${var.config_name}-${var.environment}-argocd-project"
  role         = "argocd-${var.config_name}-${var.environment}-application-controller" 
  description  = "short lived token"
  expires_in   = "10m"
  renew_before = "5m"
}

resource "argocd_repository" "argocd_private" {
  depends_on = [argocd_project.argocd_project]
  repo = "ssh://git@github.com/${var.apps_repo_name}.git"
  username        = var.github_user_name
  ssh_private_key = var.github_service_account_ssh_key
  insecure = true
}

resource "argocd_repository_credentials" "argocd_private" {
  depends_on = [argocd_project.argocd_project]
  url = "ssh://git@github.com"
  username        = var.github_user_name
  ssh_private_key = var.github_service_account_ssh_key
}

# // apps

resource "argocd_application" "helm_chart" {
  depends_on = [
    argocd_project.argocd_project,
    argocd_project_token.argocd_secret,
    argocd_repository.argocd_private,
    argocd_repository_credentials.argocd_private
  ]
  for_each = var.argocd_apps_setup
  metadata {
    name      = "${var.config_name}-${var.environment}-${each.key}"
    namespace = "argocd"
  }

  spec {
    project = "${var.config_name}-${var.environment}-argocd-project"

    source {
      repo_url        = "ssh://git@github.com/${var.apps_repo_name}.git"
      path = each.value["path"]
      target_revision = each.value["git_revision"]
    }

    sync_policy {
      automated = {
        prune       = true
        self_heal   = true
        allow_empty = true
      }
      # Only available from ArgoCD 1.5.0 onwards
      sync_options = ["Validate=false"]
      retry {
        limit   = "5"
        backoff = {
          duration     = "30s"
          max_duration = "2m"
          factor       = "2"
        }
      }
    }

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = var.k8s_namespace
    }
  }
}
