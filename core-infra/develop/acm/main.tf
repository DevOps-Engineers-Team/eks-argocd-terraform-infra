module "acm" {
  source        = "../../../modules/acm"
  environment = local.environment

  hosted_zone_name =  "${var.base_domain_name}."
  domain_name =  "*.${var.base_domain_name}"
}
