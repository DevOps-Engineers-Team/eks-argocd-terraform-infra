variable "environment" {}

variable "hosted_zone_name" {}

variable "domain_name" {}

variable "additional_names" {
    default = []
}

variable "is_private" {
  default = false
}
