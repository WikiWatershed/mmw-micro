resource "aws_route53_record" "mmw_micro" {
  zone_id = "${var.r53_public_hosted_zone_id}"
  name    = "${var.r53_public_hosted_zone_record}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.mmw_micro.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.mmw_micro.hosted_zone_id}"
    evaluate_target_health = false
  }
}
