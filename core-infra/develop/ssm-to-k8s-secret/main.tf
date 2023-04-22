module "ssm_to_kubernetes_secret" {
  for_each = local.secrets_config
  source               = "../../../modules/k8s-secret"
  name                 = each.key
  namespace            = "argocd-config-${local.environment}" 
  data                 = {
    "${each.key}" = each.value
  }
}
