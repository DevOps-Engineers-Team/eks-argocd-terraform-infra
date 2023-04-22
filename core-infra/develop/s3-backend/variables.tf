locals {
  confg_name     = basename(dirname(dirname(path.cwd)))
  environment  = basename(dirname(path.cwd))
  account_id   = data.aws_caller_identity.current.account_id

  bucket_policy_allowed_roles_arns = ["arn:aws:iam::${local.account_id}:user/sandbox-admin-cli"]
}
