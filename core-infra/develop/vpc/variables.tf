locals {
  environment   = basename(dirname(path.cwd))
  config_name = basename(dirname(dirname(path.cwd)))
  account_id   = data.aws_caller_identity.current.account_id

  public_subnets = [cidrsubnet(var.cidr, 6, 1), cidrsubnet(var.cidr, 6, 2), cidrsubnet(var.cidr, 6, 3)]
  private_subnets = [cidrsubnet(var.cidr, 6, 4), cidrsubnet(var.cidr, 6, 5), cidrsubnet(var.cidr, 6, 6)]
}

variable "cidr" {
  default = "10.83.0.0/16"
}

variable "vpc_flow_logs_retention_period" {
  description = "Retention period for VPC flow logs in days. 'auto' for 90 days for production and 30 days for non-production environments"
  default     = "auto"
}
