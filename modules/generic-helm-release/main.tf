resource "helm_release" "release" {
  name       = "${var.helm_chart_name}-${var.environment}"
  repository = var.helm_repo_url
  chart      = var.helm_chart_name
  namespace  = var.kubernetes_namespace
  create_namespace = var.create_namespace
  version    = var.helm_chart_version == "" ? null : var.helm_chart_version
  skip_crds = var.skip_crds

  values = var.helm_init_values

  dynamic "set" {
    for_each = var.helm_sets
    iterator = set
    content {
      name = set.value["name"]
      value = set.value["value"]
      type = set.value["type"]
    }
  }
}
