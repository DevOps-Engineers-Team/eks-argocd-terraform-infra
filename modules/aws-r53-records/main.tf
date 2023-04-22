resource "aws_route53_record" "dns_record" {
  zone_id  = var.zone_id
  name     = var.host_name
  type     = "CNAME"
  ttl      = "300"
  records  = [var.record_set]
}