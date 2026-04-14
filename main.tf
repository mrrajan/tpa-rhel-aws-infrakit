# Root-level Terraform configuration to invoke the TPA RHEL AWS infrastructure module

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "tpa-rhel-aws-infrakit"
      ManagedBy   = "Terraform"
      Environment = "development"
    }
  }
}

# Invoke the TPA RHEL AWS infrastructure module
module "tpa_rhel_aws" {
  source = "./tpa_rhel_aws"

  # Only expose the key variables
  project_name     = var.instance_name
  create_rds       = var.create_rds
  ssh_key_path     = var.ssh_key_path

  # All other variables use defaults from the module
}
