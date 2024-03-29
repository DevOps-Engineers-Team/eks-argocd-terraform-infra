### Backend

terraform {
  backend "s3" {
    bucket = "core-infra-gitops-terraform-backend"
    key = "develop/s3-backend/terraform.state"
    region         = "eu-west-1"
    dynamodb_table = "terraform_lock"
  }
}