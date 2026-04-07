# --------------------------------------------------------------------------
# S3 — Static website hosting bucket
# --------------------------------------------------------------------------
module "s3_hosting" {
  source = "./modules/s3-hosting"

  project_name  = var.project_name
  environment   = var.environment
  force_destroy = false
}

# --------------------------------------------------------------------------
# ACM — SSL certificate (must be in us-east-1 for CloudFront)
# --------------------------------------------------------------------------
module "acm" {
  source = "./modules/acm"

  providers = {
    aws = aws.us_east_1
  }

  domain_name = var.domain_name
}

# --------------------------------------------------------------------------
# Route 53 — DNS records (ACM validation + CloudFront ALIAS)
# --------------------------------------------------------------------------
module "route53" {
  source = "./modules/route53"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  domain_name                   = var.domain_name
  hosted_zone_id                = var.hosted_zone_id
  acm_domain_validation_options = module.acm.domain_validation_options
  acm_certificate_arn           = module.acm.certificate_arn

  # CloudFront ALIAS records
  create_cloudfront_records              = true
  cloudfront_distribution_domain_name    = module.cloudfront.distribution_domain_name
  cloudfront_distribution_hosted_zone_id = module.cloudfront.distribution_hosted_zone_id
}

# --------------------------------------------------------------------------
# CloudFront — CDN distribution with SSL and OAC
# --------------------------------------------------------------------------
module "cloudfront" {
  source = "./modules/cloudfront"

  project_name                   = var.project_name
  environment                    = var.environment
  domain_name                    = var.domain_name
  s3_bucket_id                   = module.s3_hosting.bucket_id
  s3_bucket_arn                  = module.s3_hosting.bucket_arn
  s3_bucket_regional_domain_name = module.s3_hosting.bucket_regional_domain_name
  acm_certificate_arn            = module.route53.validated_certificate_arn
}

# --------------------------------------------------------------------------
# S3 Bucket Policy — allow CloudFront OAC access (applied after both exist)
# --------------------------------------------------------------------------
resource "aws_s3_bucket_policy" "hosting" {
  bucket = module.s3_hosting.bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOAC"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${module.s3_hosting.bucket_arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = module.cloudfront.distribution_arn
          }
        }
      }
    ]
  })
}
