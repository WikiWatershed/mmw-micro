variable "project" {
  default = "MMW Micro"
}

variable "environment" {
  default = "Staging"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "logs_bucket" {}

variable "config_bucket" {}

variable "origin_bucket" {}

variable "acm_certificate_arn" {}

variable "r53_public_hosted_zone_id" {}

variable "r53_public_hosted_zone_record" {}
