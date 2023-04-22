locals {
  environment   = basename(dirname(path.cwd))
  config_name = basename(dirname(dirname(path.cwd)))

  application  = "gitops"
  cluster_name = "${local.config_name}-${local.environment}-${local.application}-cluster"
}
