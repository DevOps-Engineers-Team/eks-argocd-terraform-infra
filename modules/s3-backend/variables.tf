variable "bucket_name" {}

variable "environment" {}

variable "bucket_name_postfix" {
  default = "terraform-backend"
}

variable "bucket_policy_allowed_roles_arns" {
  type = list(string)
  default = []
}

variable "create_dynamodb_lock" {
  type = bool
  default = false
}

variable "create_kms_alias" {
  type = bool
  default = false
}