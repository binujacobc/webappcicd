variable "aws_region" {
  description = "Primary AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. production, staging)"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["production", "staging", "development"], var.environment)
    error_message = "Environment must be one of: production, staging, development."
  }
}

variable "domain_name" {
  description = "Primary domain name (e.g. binu.uk)"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route 53 hosted zone ID (created via CLI)"
  type        = string
}
