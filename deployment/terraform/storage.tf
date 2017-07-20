#
# S3 resources
#
data "aws_iam_policy_document" "mmw_micro" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.origin_bucket}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.mmw_micro.iam_arn}"]
    }
  }

  statement {
    actions = ["s3:*"]

    resources = [
      "arn:aws:s3:::${var.origin_bucket}",
      "arn:aws:s3:::${var.origin_bucket}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = ["${var.iam_publish_principal_arn}"]
    }
  }
}

resource "aws_s3_bucket" "mmw_micro" {
  bucket = "${var.origin_bucket}"
  policy = "${data.aws_iam_policy_document.mmw_micro.json}"

  tags {
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

resource "aws_s3_bucket" "mmw_micro_logs" {
  bucket = "${var.logs_bucket}"
  acl    = "log-delivery-write"

  tags {
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}
