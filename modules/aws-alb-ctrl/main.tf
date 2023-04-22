resource "kubectl_manifest" "crds_ingressclassparams" {
  yaml_body = data.template_file.crds_ingressclassparams.rendered
}

resource "kubectl_manifest" "crds_targetgroupbindings" {
  yaml_body = data.template_file.crds_targetgroupbindings.rendered
}

resource "aws_iam_role" "this" {
  name        = "${var.aws_resource_name_prefix}${local.k8s_cluster_name}-alb-ingress-controller"
  description = "Permissions required by the Kubernetes AWS ALB Ingress controller to do it's job."
  path        = local.aws_iam_path_prefix

  tags = var.aws_tags

  force_detach_policies = true

  assume_role_policy = var.k8s_cluster_type == "vanilla" ? data.aws_iam_policy_document.ec2_assume_role[0].json : data.aws_iam_policy_document.eks_oidc_assume_role[0].json
}

resource "aws_iam_policy" "this" {
  name        = "${var.aws_resource_name_prefix}${local.k8s_cluster_name}-alb-management"
  description = "Permissions that are required to manage AWS Application Load Balancers."
  path        = local.aws_iam_path_prefix
  policy      = data.aws_iam_policy_document.alb_management.json
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = aws_iam_policy.this.arn
  role       = aws_iam_role.this.name
}

resource "kubernetes_service_account" "this" {
  automount_service_account_token = true
  metadata {
    name      = "aws-alb-ingress-controller"
    namespace = var.k8s_namespace
    annotations = {
      # This annotation is only used when running on EKS which can
      # use IAM roles for service accounts.
      "eks.amazonaws.com/role-arn" = aws_iam_role.this.arn
    }
    labels = {
      "app.kubernetes.io/name"       = "aws-alb-ingress-controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "kubernetes_cluster_role" "this" {
  metadata {
    name = "aws-alb-ingress-controller"

    labels = {
      "app.kubernetes.io/name"       = "aws-alb-ingress-controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  rule {
    api_groups = [
      "",
      "extensions",
    ]

    resources = [
      "configmaps",
      "endpoints",
      "events",
      "ingresses",
      "ingresses/status",
      "services",
    ]

    verbs = [
      "create",
      "get",
      "list",
      "update",
      "watch",
      "patch",
    ]
  }

  rule {
    api_groups = [
      "",
      "extensions",
    ]

    resources = [
      "nodes",
      "pods",
      "secrets",
      "services",
      "namespaces",
    ]

    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
}

resource "kubernetes_cluster_role_binding" "this" {
  metadata {
    name = "aws-alb-ingress-controller"

    labels = {
      "app.kubernetes.io/name"       = "aws-alb-ingress-controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.this.metadata[0].name
  }

  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.this.metadata[0].name
    namespace = kubernetes_service_account.this.metadata[0].namespace
  }
}

# resource "kubernetes_deployment" "this" {
#   depends_on = [
#     kubectl_manifest.crds_ingressclassparams,
#     kubectl_manifest.crds_targetgroupbindings,
#     kubernetes_cluster_role_binding.this
#   ]

#   metadata {
#     name      = "aws-alb-ingress-controller"
#     namespace = var.k8s_namespace

#     labels = {
#       "app.kubernetes.io/name"       = "aws-alb-ingress-controller"
#       "app.kubernetes.io/version"    = "v${local.aws_alb_ingress_controller_version}"
#       "app.kubernetes.io/managed-by" = "terraform"
#     }

#     annotations = {
#       "field.cattle.io/description" = "AWS ALB Ingress Controller"
#     }
#   }

#   spec {

#     replicas = var.k8s_replicas

#     selector {
#       match_labels = {
#         "app.kubernetes.io/name" = "aws-alb-ingress-controller"
#       }
#     }

#     strategy {
#       type = "Recreate"
#     }

#     template {
#       metadata {
#         labels = merge(
#           {
#             "app.kubernetes.io/name"    = "aws-alb-ingress-controller"
#             "app.kubernetes.io/version" = local.aws_alb_ingress_controller_version
#           },
#           var.k8s_pod_labels
#         )
#         annotations = merge(
#           {
#             # Annotation which is only used by KIAM and kube2iam.
#             # Should be ignored by your cluster if using IAM roles for service accounts, e.g.
#             # when running on EKS.
#             "iam.amazonaws.com/role" = aws_iam_role.this.arn
#           },
#           var.k8s_pod_annotations
#         )
#       }

#       spec {
#         affinity {
#           pod_anti_affinity {
#             preferred_during_scheduling_ignored_during_execution {
#               weight = 100
#               pod_affinity_term {
#                 label_selector {
#                   match_expressions {
#                     key      = "app.kubernetes.io/name"
#                     operator = "In"
#                     values   = ["aws-alb-ingress-controller"]
#                   }
#                 }
#                 topology_key = "kubernetes.io/hostname"
#               }
#             }
#           }
#         }

#         automount_service_account_token = true

#         dns_policy = "ClusterFirst"

#         restart_policy = "Always"

#         container {
#           name                     = "server"
#           image                    = local.aws_alb_ingress_controller_docker_image
#           image_pull_policy        = "Always"
#           termination_message_path = "/dev/termination-log"

#           args = [
#             "--ingress-class=${local.aws_alb_ingress_class}",
#             "--cluster-name=${local.k8s_cluster_name}",
#             "--aws-vpc-id=${local.aws_vpc_id}",
#             "--aws-region=${local.aws_region_name}",
#             "--aws-max-retries=10",
#           ]

#           env {
#             name = "ENABLE_WEBHOOKS"
#             value = false
#           }

#           port {
#             name           = "health"
#             container_port = 10254
#             protocol       = "TCP"
#           }

#           readiness_probe {
#             http_get {
#               path   = "/healthz"
#               port   = "health"
#               scheme = "HTTP"
#             }

#             initial_delay_seconds = 30
#             period_seconds        = 60
#             timeout_seconds       = 3
#           }

#           liveness_probe {
#             http_get {
#               path   = "/healthz"
#               port   = "health"
#               scheme = "HTTP"
#             }

#             initial_delay_seconds = 60
#             period_seconds        = 60
#           }
#         }

#         service_account_name             = kubernetes_service_account.this.metadata[0].name
#         termination_grace_period_seconds = 60
#       }
#     }
#   }
# }

# oidc

resource "aws_iam_openid_connect_provider" "openid_connect_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cert.certificates.0.sha1_fingerprint]
  url             = local.cluster_oidc_issuer_url
}
