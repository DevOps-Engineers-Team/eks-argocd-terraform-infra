locals {
  environment   = basename(dirname(path.cwd))
  config_name = basename(dirname(dirname(path.cwd)))
  account_id    = data.aws_caller_identity.current.account_id

  application  = "gitops"
  cluster_name = "${local.config_name}-${local.environment}-${local.application}-cluster"
  k8s_namespace = "${local.config_name}-${local.environment}"
}
