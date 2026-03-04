# AWS Region
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

# Project Configuration
variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "tpa-rhel-aws"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "development"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet (EC2)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (RDS)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# EC2 Configuration
variable "ami_id" {
  description = "AMI ID for EC2 instance (RHEL)"
  type        = string
  default     = "ami-0d8d3b1122e36c000"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "m6i.2xlarge"
}

variable "root_volume_size" {
  description = "Size of root EBS volume in GB"
  type        = number
  default     = 100
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH into EC2 instance. WARNING: 0.0.0.0/0 allows access from anywhere - restrict this in production!"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ssh_key_path" {
  description = "Path where SSH private key will be saved (leave empty to auto-generate based on project name)"
  type        = string
  default     = ""
}

# RDS Configuration
variable "create_rds" {
  description = "Whether to create RDS PostgreSQL instance"
  type        = bool
  default     = false
}

variable "db_master_user" {
  description = "Master username for RDS database"
  type        = string
  default     = "postgres"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.m7g.large"
}

variable "db_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "17.2"
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS in GB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "postgres"
}
