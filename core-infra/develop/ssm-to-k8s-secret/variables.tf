locals {
  environment   = basename(dirname(path.cwd))
  config_name = basename(dirname(dirname(path.cwd)))

  infra_alias = "core-infra"
  application  = "gitops"
  cluster_name = "${local.infra_alias}-${local.environment}-${local.application}-cluster"

  secrets_config = {
    "git-pat" = data.aws_ssm_parameter.github_pat.value
  }
}
