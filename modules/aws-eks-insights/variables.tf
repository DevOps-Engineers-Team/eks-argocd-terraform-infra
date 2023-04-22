variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
}

variable "environment" {
  description = "The environment to use"
}

variable "config_name" {
  description = "The name of the Business Unit"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "default_tags" {
  default = {
    CreatedBy    = "terraform"
    MaintainedBy = "devops-engineers-team"
  }
}

variable "insight_log_groups" {
  default = [
    "performance",
    "application",
    "host",
    "dataplane"
  ]
}

variable "eks_insights_retention_period" {
  description = "Retention peropd for EKS Insights logs in days. When set to 'auto' values are 90 days for production and 30 days for non-production environments"
  default     = "auto"
}

locals {
  flow_logs_retention_days = var.eks_insights_retention_period == "auto" ? var.environment == "prod" ? 90 : 30 : var.eks_insights_retention_period
}