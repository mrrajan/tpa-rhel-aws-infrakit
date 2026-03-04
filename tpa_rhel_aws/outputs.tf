# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

# EC2 Outputs
output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.main.public_ip
}

output "ec2_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.main.private_ip
}

output "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2.id
}

# SSH Outputs
output "ssh_private_key_path" {
  description = "Path to the SSH private key file"
  value       = local_file.private_key.filename
}

output "ssh_connection_command" {
  description = "SSH command to connect to the EC2 instance"
  value       = "ssh -i ${local_file.private_key.filename} ec2-user@${aws_instance.main.public_ip}"
}

# RDS Outputs (conditional)
output "rds_endpoint" {
  description = "RDS instance endpoint (only if RDS is created)"
  value       = var.create_rds ? aws_db_instance.main[0].endpoint : null
}

output "rds_database_name" {
  description = "RDS database name (only if RDS is created)"
  value       = var.create_rds ? aws_db_instance.main[0].db_name : null
}

output "rds_username" {
  description = "RDS master username (only if RDS is created)"
  value       = var.create_rds ? aws_db_instance.main[0].username : null
}

output "rds_password" {
  description = "RDS master password (only if RDS is created)"
  value       = var.create_rds ? random_password.trustify-db-admin-password[0].result : null
  sensitive   = true
}

output "rds_connection_string" {
  description = "PostgreSQL connection string (only if RDS is created)"
  value       = var.create_rds ? "psql -h ${aws_db_instance.main[0].endpoint} -U ${var.db_master_user} -d ${var.db_name}" : null
  sensitive   = true
}
