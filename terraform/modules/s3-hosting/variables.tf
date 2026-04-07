variable "project_name" {
  description = "Project name used for bucket naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "force_destroy" {
  description = "Allow bucket deletion even when non-empty (use with caution)"
  type        = bool
  default     = false
}
