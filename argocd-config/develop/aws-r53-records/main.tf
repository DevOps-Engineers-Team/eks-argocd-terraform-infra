module "sonarqube_dns" {
  source           = "../../../modules/aws-r53-records"

  zone_id = local.sonarqube_dns["zone_id"]
  host_name = local.sonarqube_dns["host_name"]
  record_set = local.sonarqube_dns["record_set"]
}

module "jenkins_dns" {
  source           = "../../../modules/aws-r53-records"

  zone_id = local.jenkins_dns["zone_id"]
  host_name = local.jenkins_dns["host_name"]
  record_set = local.jenkins_dns["record_set"]
}
