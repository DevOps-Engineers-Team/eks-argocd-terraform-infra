module "aws-eks-insights" {
  source           = "../../../modules/aws-eks-insights"
  config_name    = local.config_name
  environment      = local.environment
  eks_cluster_name = local.cluster_name
}
