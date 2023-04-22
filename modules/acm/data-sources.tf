data "aws_route53_zone" "hosted_zone" {
  name         = var.hosted_zone_name
  private_zone = var.is_private
}
