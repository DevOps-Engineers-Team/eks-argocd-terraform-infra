locals {
    selected_aws_account_id = var.aws_account_id != null ? var.aws_account_id : data.aws_caller_identity.current.account_id
}

variable "aws_account_id" {
  # type = any
  default = null
}

variable "github_thumbprint_list" {
  type = list(string)
  default = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

variable "github_provider_url" {
  default = "https://token.actions.githubusercontent.com"
}

variable "repo_list" {
  type = list(string)
  default = []
}

# DICSCLAIMER: I am aware that this policy is way to fat, and violates POLP, yet still not hurting eyes like AdministratiorAccess.
variable "managed_policies_arns" {
  type = list(string)
  default = [
    "arn:aws:iam::aws:policy/IAMFullAccess",
    "arn:aws:iam::aws:policy/PowerUserAccess"
  ]
}

