# Root-level outputs - pass through from module

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.tpa_rhel_aws.ec2_public_ip
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = module.tpa_rhel_aws.ec2_instance_id
}

output "ssh_connection_command" {
  description = "Command to SSH into the EC2 instance"
  value       = module.tpa_rhel_aws.ssh_connection_command
}

output "ssh_private_key_path" {
  description = "Path to the SSH private key file"
  value       = module.tpa_rhel_aws.ssh_private_key_path
}

output "rds_endpoint" {
  description = "RDS instance endpoint (only if RDS is created)"
  value       = module.tpa_rhel_aws.rds_endpoint
}

output "rds_database_name" {
  description = "RDS database name (only if RDS is created)"
  value       = module.tpa_rhel_aws.rds_database_name
}

output "rds_username" {
  description = "RDS master username (only if RDS is created)"
  value       = module.tpa_rhel_aws.rds_username
}

output "rds_password" {
  description = "RDS master password (only if RDS is created) - SENSITIVE"
  value       = module.tpa_rhel_aws.rds_password
  sensitive   = true
}
