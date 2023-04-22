module "spotinst_role" {
  source        = "../../../modules/iam-spotinst"
  extid         = data.aws_ssm_parameter.ext_id.value
  spot_role_assume_account_id = data.aws_ssm_parameter.spot_role_assume_account_id.value
  current_account_id = data.aws_caller_identity.current.account_id
}
