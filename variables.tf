# Root-level variables for TPA RHEL AWS Infrastructure

variable "instance_name" {
  description = "Name for the EC2 instance and project resources"
  type        = string
  default     = "tpa-rhel-aws"
}

variable "create_rds" {
  description = "Whether to create RDS PostgreSQL instance"
  type        = bool
  default     = false
}

