data "aws_eks_cluster" "cluster" {
  name = local.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = local.cluster_name
}

data "aws_ssm_parameter" "github_pat" {
  name = "/secrets/github_pat"
}
