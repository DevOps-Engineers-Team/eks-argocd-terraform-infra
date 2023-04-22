resource "aws_iam_openid_connect_provider" "github_oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = var.github_thumbprint_list
  url             = var.github_provider_url
}

resource "aws_iam_role" "gh_oidc_role" {
  name = "gh-oidc-role"

  assume_role_policy = jsonencode({
    Version: "2008-10-17",
    Statement: [
      {
        Effect: "Allow",
        Principal: {
          Federated: "arn:aws:iam::${local.selected_aws_account_id}:oidc-provider/token.actions.githubusercontent.com"
        },
        Action: "sts:AssumeRoleWithWebIdentity",
        Condition: {
          StringLike: {
            "token.actions.githubusercontent.com:sub": tolist(flatten(var.repo_list))
          }
        }
      },
      {
        Effect: "Allow",
        Principal: {
          AWS: "arn:aws:iam::${local.selected_aws_account_id}:root"
        },
        Action: "sts:AssumeRole",
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "managed_policies_attachments" {
  count      = length(var.managed_policies_arns)
  role       = aws_iam_role.gh_oidc_role.name
  policy_arn = element(var.managed_policies_arns, count.index)
}
