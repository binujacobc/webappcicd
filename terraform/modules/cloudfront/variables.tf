variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "domain_name" {
  description = "Primary domain name"
  type        = string
}

variable "s3_bucket_id" {
  description = "S3 hosting bucket ID"
  type        = string
}

variable "s3_bucket_arn" {
  description = "S3 hosting bucket ARN"
  type        = string
}

variable "s3_bucket_regional_domain_name" {
  description = "S3 bucket regional domain name for origin"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN (must be in us-east-1)"
  type        = string
}
