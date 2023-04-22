module "vpc" {
  source      = "../../../modules/data-vpc"
  environment = local.environment
  config_name  = local.config_name
  vpc_name = "${local.config_name}-${local.environment}-vpc"
}

module "user_data" {
  source = "./user-data"
  cluster_name = local.cluster_name
  role_arn_to_assume = local.roles_arns_to_assume[0]
}

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "spotinst_token" {
  name = "/secrets/${local.config_name}/${local.environment}/spot_token"
}

data "aws_ssm_parameter" "spotinst_account" {
  name = "/config/${local.config_name}/${local.environment}/spot_account_id"
}
