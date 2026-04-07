# --------------------------------------------------------------------------
# Origin Access Control — secure S3 access (replaces legacy OAI)
# --------------------------------------------------------------------------
resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "${var.project_name}-${var.environment}-oac"
  description                       = "OAC for ${var.project_name} S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# --------------------------------------------------------------------------
# CloudFront Distribution
# --------------------------------------------------------------------------
resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.project_name} ${var.environment}"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  aliases             = [var.domain_name, "www.${var.domain_name}"]
  http_version        = "http2and3"

  # S3 Origin
  origin {
    domain_name              = var.s3_bucket_regional_domain_name
    origin_id                = "s3-${var.s3_bucket_id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  # Default cache behavior
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-${var.s3_bucket_id}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    # Use managed caching policy — CachingOptimized
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"

    # Use managed response headers policy — SecurityHeadersPolicy
    response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"
  }

  # SPA routing — serve index.html for 403/404
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  # SSL configuration
  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # No geo restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}"
  }
}
