
terraform {
  backend "s3" {
    bucket = "argocd-config-gitops-terraform-backend"
    key = "develop/eks-demo-gitops-apps/terraform.state"
    region = "eu-west-1"
    dynamodb_table = "terraform_lock"
  }
}
