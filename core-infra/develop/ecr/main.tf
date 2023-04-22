module "ecr" {
  for_each = local.ecr_config
  source = "../../../modules/ecr"
  repo_name = each.value["name"]
  repo_pull_permissions = var.repo_pull_permissions
  repo_push_permissions = var.repo_push_permissions
}
