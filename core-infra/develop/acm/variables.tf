locals {
  environment   = basename(dirname(path.cwd))
  config_name = basename(dirname(dirname(path.cwd)))
}

variable "base_domain_name" {
  default = "witold-demo.com"
}