# --------------------------------------------------------------------------
# ACM DNS Validation Records
# --------------------------------------------------------------------------
resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in var.acm_domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id         = var.hosted_zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 300
  allow_overwrite = true

  records = [each.value.record]
}

# --------------------------------------------------------------------------
# ACM Certificate Validation Waiter
# --------------------------------------------------------------------------
resource "aws_acm_certificate_validation" "this" {
  provider = aws.us_east_1

  certificate_arn         = var.acm_certificate_arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}

# --------------------------------------------------------------------------
# CloudFront ALIAS Records — apex and www
# --------------------------------------------------------------------------
resource "aws_route53_record" "apex" {
  count = var.create_cloudfront_records ? 1 : 0

  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.cloudfront_distribution_domain_name
    zone_id                = var.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  count = var.create_cloudfront_records ? 1 : 0

  zone_id = var.hosted_zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.cloudfront_distribution_domain_name
    zone_id                = var.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = false
  }
}
