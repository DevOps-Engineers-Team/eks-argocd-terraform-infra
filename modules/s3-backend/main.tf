resource "aws_dynamodb_table" "terraform_lock" {
  count = var.create_dynamodb_lock ? 1: 0
  name           = "terraform_lock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# s3 kms key
resource "aws_kms_key" "s3_key" {
  description             = "s3 kms key for server side encryption"
  is_enabled              = true
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "s3_key_alias" {
  count = var.create_kms_alias ? 1 : 0
  name          = "alias/master-s3"
  target_key_id = aws_kms_key.s3_key.key_id
}

resource "aws_s3_bucket" "backend" {
  bucket = "${var.bucket_name}-${var.bucket_name_postfix}"
  policy = data.aws_iam_policy_document.allow_access_from_other_envs.json

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "versioning"
    enabled = true

    abort_incomplete_multipart_upload_days = 7

    expiration {
      expired_object_delete_marker = true
    }

    noncurrent_version_expiration {
      days = 90
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.s3_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

data "aws_iam_policy_document" "allow_access_from_other_envs" {
  statement {
    sid = "1"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
    ]

    effect = "Allow"

    resources = [
      "arn:aws:s3:::${var.bucket_name}-${var.bucket_name_postfix}/*",
      "arn:aws:s3:::${var.bucket_name}-${var.bucket_name_postfix}",
    ]

    principals {
      type        = "AWS"
      identifiers = tolist(var.bucket_policy_allowed_roles_arns)
    }
  }
}


### Outputs

output "terraform_backend_s3_bucket_id" {
  value = aws_s3_bucket.backend.id
}

output "terraform_backend_s3_bucket_arn" {
  value = aws_s3_bucket.backend.arn
}

output "s3_kms_key_arn" {
  value = aws_kms_key.s3_key.arn
}