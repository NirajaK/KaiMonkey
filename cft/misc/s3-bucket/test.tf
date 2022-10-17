resource "aws_s3_bucket" "mybucket" {
  bucket = "mybucket"
  acl    = "public"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "<kms_master_key_id>"
      }
    }
  }

  versioning {
    enabled = true
  }

  versioning {
    enabled    = true
    mfa_delete = true
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_bucket_policy" "b" {
  bucket = aws_s3_bucket.b.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "MYBUCKETPOLICY"
    Statement = [
      {
        Sid       = "IPAllow"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.b.arn,
          "${aws_s3_bucket.b.arn}/*",
        ]
        Condition = {
          IpAddress = {
            "aws:SourceIp" = "8.8.8.8/32"
          }
        }
      },
    ]
  })
}

resource "aws_s3_bucket_policy" "mybucketpolicy" {
  bucket = aws_s3_bucket.mybucket.id

  policy = <<POLICY
        {
            "Version": "2012-10-17",
            "Statement": [
              {
                  "Sid": "mybucket-restrict-access-to-users-or-roles",
                  "Effect": "Allow",
                  "Principal": [
                    {
                       "AWS": [
                          "<aws_policy_role_arn>"
                        ]
                    }
                  ],
                  "Action": "s3:GetObject",
                  "Resource": "arn:aws:s3:::mybucket/*"
              }
            ]
        }
    POLICY
}