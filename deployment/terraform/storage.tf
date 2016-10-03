#
# S3 resources
#
data "template_file" "read_only_bucket_policy" {
  template = "${file("policies/s3-read-only-anonymous-user.json")}"

  vars {
    bucket = "${var.origin_bucket}"
  }
}

data "template_file" "server_side_encryption_policy" {
  template = "${file("policies/s3-server-side-encryption.json")}"

  vars {
    bucket = "${var.config_bucket}"
  }
}

resource "aws_s3_bucket" "mmw_micro" {
  bucket = "${var.origin_bucket}"
  policy = "${data.template_file.read_only_bucket_policy.rendered}"

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
