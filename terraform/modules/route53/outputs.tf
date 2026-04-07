output "validated_certificate_arn" {
  description = "Validated ACM certificate ARN"
  value       = aws_acm_certificate_validation.this.certificate_arn
}

output "acm_validation_record_fqdns" {
  description = "FQDNs of ACM validation records"
  value       = [for record in aws_route53_record.acm_validation : record.fqdn]
}
