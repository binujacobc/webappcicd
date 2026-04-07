output "bucket_id" {
  description = "S3 bucket ID"
  value       = aws_s3_bucket.hosting.id
}

output "bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.hosting.bucket
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.hosting.arn
}

output "bucket_regional_domain_name" {
  description = "S3 bucket regional domain name"
  value       = aws_s3_bucket.hosting.bucket_regional_domain_name
}
