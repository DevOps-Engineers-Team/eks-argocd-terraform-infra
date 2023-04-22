# eks-argocd-terraform-infra
Pure full IaaC configuration of EKS and ArgoCD written in Terraform to quickly get GitOps expierence

        .github
        └── workflows
            ├── first-terraform-plan.yml
            └── later-terraform-apply.yml

        core-infra
        └── develop
            ├── acm
            ├── aws-alb-ctrl
            ├── ecr
            ├── eks-insights
            ├── eks-ocean-cluster
            ├── helm-alb-ctrl
            ├── helm-argocd
            ├── helm-cert-manager
            ├── iam-oidc
            ├── iam-spotinst
            ├── s3-backend
            ├── ssm-to-k8s-secret
            └── vpc

        argocd-config
        └── develop
            ├── aws-r53-records
            ├── gitops-apps
            └── s3-backend

        modules
        ├── acm
        ├── argocd-config
        ├── argocd-helm-release
        ├── aws-alb-ctrl
        ├── aws-eks-cluster
        ├── aws-eks-insights
        ├── aws-r53-records
        ├── data-vpc
        ├── ecr
        ├── generic-helm-release
        ├── iam-oidc
        ├── iam-spotinst
        ├── k8s-namespace
        ├── k8s-secret
        ├── s3-backend
        ├── spotinst-eks-ocean
        ├── spotinst-ocean-controller
        └── vpc