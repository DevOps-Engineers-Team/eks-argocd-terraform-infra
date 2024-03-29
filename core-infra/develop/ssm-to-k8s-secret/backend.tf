### Backend

terraform {
  backend "s3" {
    bucket = "core-infra-gitops-terraform-backend"
    key = "develop/ssm-to-k8s-secret/terraform.state"
    region         = "eu-west-1"
    dynamodb_table = "terraform_lock"
  }
}