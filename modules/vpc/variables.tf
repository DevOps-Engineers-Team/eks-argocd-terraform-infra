variable "config_name" {
  description = "Unit alias used in resource identification"
}

variable "environment" {
  description = "Environment to be used on all the resources as identifier"
  default     = "na"
}

variable "cidr" {
  description = "The CIDR block for the VPC"
  default     = ""
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  default     = "default"
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  default     = []
  type        = list(string)
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  default     = []
  type        = list(string)
}

variable "azs" {
  description = "A list of availability zones in the region"
  default     = []
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  default     = false
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  default     = true
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  default     = false
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = false
}

variable "map_public_ip_on_launch" {
  description = "Should be false if you do not want to auto-assign public IP on launch"
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Should be true if you want to create a new VPN Gateway resource and attach it to the VPC"
  default     = false
}

variable "private_propagating_vgws" {
  description = "A list of VGWs the private route table should propagate"
  default     = []
}

variable "public_propagating_vgws" {
  description = "A list of VGWs the public route table should propagate"
  default     = []
}

variable "default_tags" {
  description = "A map of tags to add to all resources"

  default = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"

  default = {
    Tier = "public"
  }
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"

  default = {
    Tier = "private"
  }
}

variable "public_route_table_tags" {
  description = "Additional tags for the public route tables"
  default     = {}
}

variable "private_route_table_tags" {
  description = "Additional tags for the private route tables"
  default     = {}
}

variable "office_cidrs" {
  type = list(string)

  default = []
}

variable "enable_vpc_flow_logs" {
  description = "Should be true to enable flow logs for the VPC"
  default     = true
}

variable "cloudwatch_vpc_flow_logs_group" {
  description = "Name of the CloudWatch log gorup for VPC flow logs"
}

variable "vpc_flow_logs_retention_period" {
  description = "Retention period for VPC flow logs in days. When set to 'auto' values are 90 days for production and 30 days for non-production environments"
  default     = "auto"
}

locals {
  flow_logs_retention_days = var.vpc_flow_logs_retention_period == "auto" ? var.environment == "prod" ? 90 : 30 : var.vpc_flow_logs_retention_period
  az = substr(var.azs[0], -1, -1)
}