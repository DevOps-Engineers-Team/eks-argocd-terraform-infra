data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "ext_id" {
  name = "/config/${local.config_name}/${local.environment}/ext_id"
}

data "aws_ssm_parameter" "spot_role_assume_account_id" {
  name = "/config/${local.config_name}/${local.environment}/spot_role_assume_account_id"
}
