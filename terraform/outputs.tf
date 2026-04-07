output "s3_bucket_name" {
  description = "Name of the S3 hosting bucket"
  value       = module.s3_hosting.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 hosting bucket"
  value       = module.s3_hosting.bucket_arn
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cloudfront.distribution_id
}

output "cloudfront_distribution_domain" {
  description = "CloudFront distribution domain name"
  value       = module.cloudfront.distribution_domain_name
}

output "acm_certificate_arn" {
  description = "ARN of the validated ACM certificate"
  value       = module.route53.validated_certificate_arn
}

output "site_urls" {
  description = "URLs where the site is accessible"
  value = {
    apex = "https://${var.domain_name}"
    www  = "https://www.${var.domain_name}"
  }
}
