### resources
resource "aws_ecr_repository" "this" {
  name = var.repo_name
}

resource "aws_ecr_repository_policy" "this" {
  repository = aws_ecr_repository.this.name

    policy = jsonencode({
        Version = "2008-10-17"
        Statement = [
            {
                Sid = "EcrPullPermission"
                Principal = {
                    AWS = var.repo_pull_permissions
                }
                Action = [
                    "ecr:BatchCheckLayerAvailability",
                    "ecr:BatchGetImage",
                    "ecr:GetDownloadUrlForLayer",
                    "ecr:ListImages"
                ]
                Effect   = "Allow"
            },
            {
                Sid = "EcrPushAndManagePermission"
                Principal = {
                    AWS = var.repo_push_permissions
                }
                Action = [
                    "ecr:BatchCheckLayerAvailability",
                    "ecr:BatchGetImage",
                    "ecr:CompleteLayerUpload",
                    "ecr:DescribeImages",
                    "ecr:DescribeRepositories",
                    "ecr:GetDownloadUrlForLayer",
                    "ecr:GetRepositoryPolicy",
                    "ecr:InitiateLayerUpload",
                    "ecr:ListImages",
                    "ecr:PutImage",
                    "ecr:UploadLayerPart"
                ]
                Effect   = "Allow"
            }
        ]
    })
}
