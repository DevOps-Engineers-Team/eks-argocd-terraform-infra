module "ingress_alb" {
  source = "../../../modules/aws-alb-ctrl"
  environment   = local.environment
  config_name = local.config_name
  account_id    = local.account_id

  cluster_name = local.cluster_name
  k8s_namespace = local.k8s_namespace
}
