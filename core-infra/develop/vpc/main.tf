### Resources

module "vpc" {
  source = "../../../modules/vpc"

  environment = local.environment
  cidr        = var.cidr

  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true

  enable_vpn_gateway = false

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets
  config_name   = local.config_name

  cloudwatch_vpc_flow_logs_group = "/${local.environment}/vpc_flow_logs"
  vpc_flow_logs_retention_period = var.vpc_flow_logs_retention_period

  default_tags = {}

  public_subnet_tags = {
    Tier                     = "public"
  }

  private_subnet_tags = {
    Tier                              = "private"
  }
}

### Outputs

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = module.vpc.default_security_group_id
}

output "default_network_acl_id" {
  description = "The ID of the default network ACL"
  value       = module.vpc.default_network_acl_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = [module.vpc.private_subnets]
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = [module.vpc.private_subnets_cidr_blocks]
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = [module.vpc.public_subnets]
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = [module.vpc.public_subnets_cidr_blocks]
}
