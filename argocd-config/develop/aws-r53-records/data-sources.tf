data "aws_eks_cluster" "cluster" {
  name = local.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = local.cluster_name
}

data "aws_route53_zone" "public" {
  name         = "witold-demo.com."
  private_zone = false
}

data "kubernetes_ingress" "public_ingress" {
  metadata {
    name = "demo-ingress"
    namespace = local.k8s_namespace
  }
}
