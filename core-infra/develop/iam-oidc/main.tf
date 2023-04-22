module "oidc_role" {
  source        = "../../../modules/iam-oidc"
  repo_list = var.repo_list
}
