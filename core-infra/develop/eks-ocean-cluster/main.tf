module "ocean-eks" {
  source = "../../../modules/spotinst-eks-ocean"

  providers = {
    aws = aws
  }
  
  # Credentials.
  spotinst_token   = data.aws_ssm_parameter.spotinst_token.value
  spotinst_account = local.spotinst_act

  vpc_id       = module.vpc.vpc_id
  subnets      = module.vpc.private_subnet_ids
  workers_group_defaults = {
     root_volume_type              = "gp2"   
  }

  # Configuration.
  cluster_version = var.cluster_version
  cluster_name       = local.cluster_name
  root_volume_size   = 120
  min_size           = var.min_size
  max_size           = var.max_size
  desired_capacity   = var.desired_capacity
  map_roles          = local.map_roles

  whitelist = var.whitelist_ec2_types

  worker_user_data = module.user_data.shell_script
}

resource "aws_iam_role_policy_attachment" "workers_managed_policies" {
  count      = length(var.workers_managed_policies)
  role       = module.ocean-eks.worker_iam_role_name
  policy_arn = element(var.workers_managed_policies, count.index)
}

resource "aws_iam_role_policy" "assume_role_inline_police" {
  name = "${local.cluster_name}-${local.environment}-assume-role"
  role = module.ocean-eks.worker_iam_role_name
  policy = templatefile("./iam-policies/sts-assume-role.json", {
    iam_roles_arns = jsonencode(local.roles_arns_to_assume)
  })
}

resource "aws_iam_role_policy" "alb_ctrl_policy" {
  name = "${local.cluster_name}-${local.environment}-assume-role"
  role = module.ocean-eks.worker_iam_role_name
  policy = templatefile("./iam-policies/alb-ctrl-policy.json", {})
}

###

resource "kubernetes_namespace" "ns" {
  depends_on = [module.ocean-eks]
  count = local.k8s_namespace != "default" ? 1 : 0
  metadata {
    name = local.k8s_namespace
  }
}