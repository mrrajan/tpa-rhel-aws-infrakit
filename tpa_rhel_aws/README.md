# TPA RHEL AWS Infrastructure

This repository contains OpenTofu/Terraform infrastructure code to provision AWS resources for RHEL-based applications.

## Architecture

**Infrastructure Components:**
- **VPC**: Custom VPC (10.0.0.0/16) with public and private subnets
- **EC2 Instance**: RHEL instance (m6i.2xlarge, 100GB storage) in public subnet
- **RDS PostgreSQL** (Optional): PostgreSQL 17.2 (db.m7g.large) in private subnets
- **Security**: EC2 in public subnet with internet access, RDS in private subnets (accessible only from EC2)

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) or [OpenTofu](https://opentofu.org/) >= 1.0
- AWS CLI configured with appropriate credentials
- AWS account with permissions to create VPC, EC2, RDS, and related resources

## Quick Start

### 1. Initialize Terraform

```bash
cd tpa_rhel_aws
terraform init
```

### 2. Deploy EC2 Only (No Database)

```bash
terraform plan
terraform apply
```

### 3. Deploy EC2 + RDS PostgreSQL

```bash
terraform plan -var="create_rds=true"
terraform apply -var="create_rds=true"
```

### 4. Connect to EC2 Instance

```bash
# Get SSH command from output
terraform output ssh_connection_command

# Or connect directly
ssh -i ssh-key.pem ec2-user@$(terraform output -raw ec2_public_ip)
```

### 5. Connect to RDS (if created)

```bash
# From your local machine (first SSH to EC2)
ssh -i ssh-key.pem ec2-user@$(terraform output -raw ec2_public_ip)

# From EC2 instance, install PostgreSQL client
sudo dnf install -y postgresql

# Get connection details
terraform output rds_endpoint
terraform output rds_password

# Connect to database
psql -h <rds-endpoint> -U postgres -d postgres
```

## Configuration

### Variables

All variables are defined in `variables.tf` with sensible defaults. You can override them by:

1. Creating a `terraform.tfvars` file (see `terraform.tfvars.example`)
2. Using `-var` flags: `terraform apply -var="instance_type=m6i.xlarge"`
3. Using environment variables: `export TF_VAR_instance_type=m6i.xlarge`

### Key Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | us-east-1 | AWS region |
| `ami_id` | ami-0d8d3b1122e36c000 | RHEL AMI ID (parameterized) |
| `instance_type` | m6i.2xlarge | EC2 instance type |
| `root_volume_size` | 100 | Root volume size in GB |
| `create_rds` | false | Whether to create RDS instance |
| `db_instance_class` | db.m7g.large | RDS instance class |
| `db_engine_version` | 17.2 | PostgreSQL version |
| `ssh_allowed_cidr` | 0.0.0.0/0 | CIDR for SSH access ⚠️ |

⚠️ **Security Warning**: The default SSH configuration allows access from anywhere (0.0.0.0/0). For production use, restrict this to your IP:

```bash
terraform apply -var="ssh_allowed_cidr=YOUR_IP/32"
```

## Outputs

After successful deployment, Terraform provides useful outputs:

```bash
# View all outputs
terraform output

# Specific outputs
terraform output ec2_public_ip
terraform output ssh_connection_command
terraform output rds_endpoint
terraform output rds_password  # Sensitive - only shown once
```

## Security Features

✅ **Network Isolation**
- EC2 in public subnet (internet-accessible)
- RDS in private subnets (no internet access)
- Security groups with least-privilege access

✅ **Encryption**
- EBS volumes encrypted at rest
- RDS storage encrypted at rest
- TLS in transit supported

✅ **Access Control**
- RDS only accessible from EC2 security group
- SSH access configurable via variable
- Auto-generated strong RDS password (32 characters)

✅ **Secrets Management**
- SSH private key saved locally with 0600 permissions
- RDS password auto-generated
- Sensitive outputs marked as sensitive

## File Structure

```
tpa_rhel_aws/
├── main.tf               # Provider configuration
├── variables.tf          # Variable definitions
├── vpc.tf               # VPC, subnets, IGW, route tables
├── security_groups.tf   # Security groups for EC2 and RDS
├── ec2.tf               # EC2 instance configuration
├── ssh_key.tf           # SSH key generation and storage
├── database.tf          # Optional RDS PostgreSQL
├── outputs.tf           # Output values
├── .gitignore           # Git ignore rules
└── terraform.tfvars.example  # Example variables file
```

## Common Operations

### Change EC2 Instance Type

```bash
terraform apply -var="instance_type=m6i.xlarge"
```

### Enable RDS Database

```bash
terraform apply -var="create_rds=true"
```

### Disable RDS Database

```bash
terraform apply -var="create_rds=false"
```

### Restrict SSH Access to Your IP

```bash
terraform apply -var="ssh_allowed_cidr=$(curl -s ifconfig.me)/32"
```

### Destroy All Resources

```bash
terraform destroy
```

## Verification

### Verify EC2 Instance

```bash
# Check instance status
aws ec2 describe-instances --instance-ids $(terraform output -raw ec2_instance_id)

# Test SSH connectivity
ssh -i ssh-key.pem ec2-user@$(terraform output -raw ec2_public_ip)

# Verify storage
ssh -i ssh-key.pem ec2-user@$(terraform output -raw ec2_public_ip) "lsblk"
```

### Verify RDS Instance

```bash
# Check RDS status
aws rds describe-db-instances --db-instance-identifier tpa-rhel-aws-postgres

# Verify not publicly accessible
aws rds describe-db-instances --query 'DBInstances[0].PubliclyAccessible'

# Test database connection from EC2
ssh -i ssh-key.pem ec2-user@$(terraform output -raw ec2_public_ip)
psql -h $(terraform output -raw rds_endpoint) -U postgres -d postgres -c "SELECT version();"
```

### Verify Security Groups

```bash
# EC2 security group rules
aws ec2 describe-security-groups --group-ids $(terraform output -raw ec2_security_group_id)

# Verify SSH, HTTP, HTTPS ports
nmap -p 22,80,443 $(terraform output -raw ec2_public_ip)
```

## Production Considerations

For production deployments, consider these enhancements:

- [ ] Use remote state (S3 + DynamoDB)
- [ ] Enable RDS multi-AZ for high availability
- [ ] Configure RDS automated backups
- [ ] Restrict SSH to specific IP ranges
- [ ] Use AWS Secrets Manager for RDS password
- [ ] Add CloudWatch monitoring and alarms
- [ ] Enable VPC Flow Logs
- [ ] Add backup/snapshot policies
- [ ] Implement proper tagging strategy
- [ ] Use AWS Systems Manager Session Manager instead of SSH

## Cost Estimation

Approximate monthly costs (us-east-1):
- VPC, Subnets, IGW: Free
- EC2 m6i.2xlarge: ~$280/month
- EBS gp3 100GB: ~$8/month
- RDS db.m7g.large: ~$150/month
- RDS storage 20GB: ~$2.30/month

**Total**: ~$290/month (EC2 only) or ~$440/month (EC2 + RDS)

## Troubleshooting

### SSH Connection Refused

```bash
# Check security group allows your IP
terraform output ec2_public_ip
curl -s ifconfig.me  # Your current IP

# Verify instance is running
aws ec2 describe-instances --instance-ids $(terraform output -raw ec2_instance_id) \
  --query 'Reservations[0].Instances[0].State.Name'
```

### RDS Connection Timeout

RDS is in private subnets - you must connect from the EC2 instance, not directly from your machine.

### Permission Denied (SSH Key)

```bash
# Fix key permissions
chmod 600 ssh-key.pem
```

## Support

For issues or questions:
- Review [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- Check AWS service limits and quotas
- Verify AWS credentials and permissions

## License

This infrastructure code is provided as-is for use with the TPA RHEL AWS project.
