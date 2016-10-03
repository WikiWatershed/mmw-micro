resource "aws_cloudfront_distribution" "mmw_micro" {
  origin {
    domain_name = "${aws_s3_bucket.mmw_micro.id}.s3.amazonaws.com"
    origin_id   = "mmwMicroOriginEastId"
  }

  enabled             = true
  comment             = "MMW Micro (${var.environment})"
  default_root_object = "index.html"
  retain_on_delete    = true

  price_class = "PriceClass_All"
  aliases     = ["${var.r53_public_hosted_zone_record}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "mmwMicroOriginEastId"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    # Only applies if the origin adds Cache-Control headers. The
    # CloudFront default is also 0.
    min_ttl = 0

    # Five minutes, and only applies when the origin DOES NOT
    # supply Cache-Control headers.
    default_ttl = 300

    # One day, but only applies if the origin adds Cache-Control
    # headers. The CloudFront default is 31536000 (one year).
    max_ttl = 86400
  }

  logging_config {
    include_cookies = false
    bucket          = "${aws_s3_bucket.mmw_micro_logs.id}.s3.amazonaws.com"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "${var.acm_certificate_arn}"
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
  }
}
