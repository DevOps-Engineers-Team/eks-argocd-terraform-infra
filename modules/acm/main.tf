resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  subject_alternative_names = var.additional_names
  validation_method = "EMAIL" # "DNS"
  # https://github.com/hashicorp/terraform-provider-aws/issues/9338

  tags = {
    Name         = var.hosted_zone_name
    Environment  = var.environment
    Tier         = "public"
  }
}

# resource "aws_route53_record" "cert_dns_entry" {
#   zone_id  = data.aws_route53_zone.hosted_zone.zone_id
#   ttl      = "60"

#   for_each = {
#     for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }
#   name            = each.value.name
#   records         = [each.value.record]
#   type            = each.value.type
# }

# resource "aws_acm_certificate_validation" "cert_valid" {
#   certificate_arn         = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [for record in aws_route53_record.cert_dns_entry : record.fqdn]
# }
