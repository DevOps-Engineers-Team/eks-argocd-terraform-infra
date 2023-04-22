module "vpc" {
  source      = "../../../modules/data-vpc"
  environment = local.environment
  config_name  = local.config_name
  vpc_name = "${local.config_name}-${local.environment}-vpc"
}

