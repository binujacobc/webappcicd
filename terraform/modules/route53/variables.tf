variable "domain_name" {
  description = "Primary domain name"
  type        = string
}

variable "hosted_zone_id" {
  description = "Existing Route 53 hosted zone ID"
  type        = string
}

variable "acm_domain_validation_options" {
  description = "ACM certificate domain validation options"
  type = set(object({
    domain_name           = string
    resource_record_name  = string
    resource_record_type  = string
    resource_record_value = string
  }))
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for validation"
  type        = string
}

variable "cloudfront_distribution_domain_name" {
  description = "CloudFront distribution domain name for ALIAS records"
  type        = string
  default     = ""
}

variable "cloudfront_distribution_hosted_zone_id" {
  description = "CloudFront distribution hosted zone ID for ALIAS records"
  type        = string
  default     = ""
}

variable "create_cloudfront_records" {
  description = "Whether to create CloudFront ALIAS records (set to true after CloudFront is created)"
  type        = bool
  default     = false
}
