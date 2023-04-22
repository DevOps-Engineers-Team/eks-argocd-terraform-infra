terraform {
  backend "s3" {
    bucket = "core-infra-gitops-terraform-backend"
    key = "develop/alb-ctrl-helm-chart/terraform.state"
    region = "eu-west-1"
    dynamodb_table = "terraform_lock"
  }
}