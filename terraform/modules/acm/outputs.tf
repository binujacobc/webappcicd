output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.this.arn
}

output "domain_validation_options" {
  description = "Domain validation options for DNS validation"
  value       = aws_acm_certificate.this.domain_validation_options
}
