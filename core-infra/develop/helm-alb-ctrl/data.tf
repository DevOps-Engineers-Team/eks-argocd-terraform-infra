data "aws_eks_cluster" "cluster" {
  name = local.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = local.cluster_name
}

data "aws_acm_certificate" "cert" {
  domain   = "*.${var.target_domain}"
}

data "aws_route53_zone" "public" {
  name         = "${var.target_domain}."
  private_zone = false
}

