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

variable "ssh_key_path" {
  description = "Path where SSH private key will be saved (leave empty to auto-generate based on project name)"
  type        = string
  default     = ""
}
