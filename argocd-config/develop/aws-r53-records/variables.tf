locals {
  environment   = basename(dirname(path.cwd))
  config_name = basename(dirname(dirname(path.cwd)))
  
  infra_alias = "core-infra"

  application  = "gitops"
  cluster_name = "${local.infra_alias}-${local.environment}-${local.application}-cluster"
  k8s_namespace = "${local.config_name}-${local.environment}"

  sonarqube_dns = {
    zone_id = data.aws_route53_zone.public.zone_id
    host_name = "sonarqube.witold-demo.com"
    record_set = data.kubernetes_ingress.public_ingress.status.0.load_balancer.0.ingress.0.hostname
  }

  jenkins_dns = {
    zone_id = data.aws_route53_zone.public.zone_id
    host_name = "jenkins.witold-demo.com"
    record_set = data.kubernetes_ingress.public_ingress.status.0.load_balancer.0.ingress.0.hostname
  }
}
