terraform {
  backend "s3" {
    bucket = "core-infra-gitops-terraform-backend"
    key = "develop/eks-demo-alb-ctrl/terraform.state"
    region = "eu-west-1"
    dynamodb_table = "terraform_lock"
  }
}