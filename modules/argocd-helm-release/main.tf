resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.kubernetes_argocd_namespace
  }
}

resource "helm_release" "argocd" {
  depends_on = [kubernetes_namespace.argocd]

  name       = "argocd-${var.config_name}-${var.environment}"
  repository = var.helm_repo_url
  chart      = "argo-cd"
  namespace  = var.kubernetes_argocd_namespace
  version    = var.argocd_helm_chart_version == "" ? null : var.argocd_helm_chart_version

  values = [
    templatefile(
      "${path.module}/templates/values.yaml.tpl",
      {
        "argocd_server_host"          = var.argocd_server_host
        "eks_iam_argocd_role_arn"     = data.aws_iam_role.argocd.arn
        "argocd_github_client_id"     = var.argocd_github_client_id
        "argocd_github_client_secret" = var.argocd_github_client_secret
        "argocd_github_org_name"      = var.argocd_github_org_name

        "argocd_ingress_enabled"                 = var.argocd_ingress_enabled
        "argocd_ingress_tls_acme_enabled"        = var.argocd_ingress_tls_acme_enabled
        "argocd_ingress_ssl_passthrough_enabled" = var.argocd_ingress_ssl_passthrough_enabled
        "argocd_ingress_class"                   = var.argocd_ingress_class
        "argocd_ingress_tls_secret_name"         = var.argocd_ingress_tls_secret_name

        "github_team"         = var.github_team
        "argocd_project_name"         = var.argocd_project_name
      }
    )
  ]

  set {
    name = "server.service.type"
    value = "NodePort"
    type = "string"
  }

  # dynamic "set" {
  #   for_each = local.helm_settings
  #   content {
  #     name  = set.key
  #     value = set.value
  #     type = "string"
  #   }
  # }
}

data "kubernetes_service" "argo_nodeport" {
  depends_on = [helm_release.argocd]
  metadata {
    name = "argocd-${var.config_name}-${var.environment}-server"
    namespace = var.kubernetes_argocd_namespace
  }
}

resource "kubernetes_ingress" "argocd_ingress" {
  depends_on = [helm_release.argocd]

  wait_for_load_balancer = true
  metadata {
    name = "argocd-${var.config_name}-${var.environment}-alb-ingress"
    namespace = var.kubernetes_argocd_namespace
    annotations = {
      "kubernetes.io/ingress.class"                    = "alb"
      "alb.ingress.kubernetes.io/load-balancer-name" = "argocd-${var.config_name}-${var.environment}-alb-ingress"
      "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
      "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/"
      "alb.ingress.kubernetes.io/certificate-arn"      = data.aws_acm_certificate.cert.arn
      "alb.ingress.kubernetes.io/listen-ports"         = <<JSON
      [{"HTTP": 80}, {"HTTPS":443}]
      JSON
      "alb.ingress.kubernetes.io/actions.ssl-redirect" = <<JSON
      {"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}
      JSON
    }
  }
  spec {
    rule {
      host = var.argocd_server_host
      http {
        path {
          backend {
            service_name = "ssl-redirect"
            service_port = "use-annotation"
          }
        }
        path {
          backend {
            service_name = "argocd-${var.config_name}-${var.environment}-server"
            service_port =  443
          }
        }
      }
    }
  }
}

resource "aws_route53_record" "argocd_ingress_record" {
  depends_on = [helm_release.argocd]
  zone_id  = data.aws_route53_zone.public.zone_id
  name     = var.argocd_server_host
  type     = "CNAME"
  ttl      = "300"
  records  = [kubernetes_ingress.argocd_ingress.status.0.load_balancer.0.ingress.0.hostname]
}

data "kubernetes_secret" "argocd_server_secret" {
  depends_on = [helm_release.argocd]
  metadata {
    name = "argocd-initial-admin-secret"
    namespace = var.kubernetes_argocd_namespace
  }
}

resource "aws_ssm_parameter" "argocd_auth_token" {
  depends_on = [helm_release.argocd]
  name  = "/secrets/${var.config_name}/${var.environment}/argocd_auth_token"
  type  = "SecureString"

  value = data.kubernetes_secret.argocd_server_secret.data["password"]
}
