
terraform {
  backend "s3" {
    bucket = "core-infra-gitops-terraform-backend"
    key = "develop/eks-demo-argocd-helm-custom/terraform.state"
    region = "eu-west-1"
    dynamodb_table = "terraform_lock"
  }
}
