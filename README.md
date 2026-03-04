# TPA RHEL AWS Infrastructure Kit

OpenTofu/Terraform infrastructure to provision AWS EC2 instances (RHEL) with optional RDS PostgreSQL database.

## Quick Start

### 1. Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) or [OpenTofu](https://opentofu.org/) >= 1.0
- AWS CLI configured with credentials
- AWS account with permissions for VPC, EC2, and RDS

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Deploy Infrastructure

**EC2 Only (No Database):**
```bash
terraform apply
```

**EC2 + RDS PostgreSQL:**
```bash
terraform apply -var="create_rds=true"
```

**Custom Instance Name:**
```bash
terraform apply -var="instance_name=my-rhel-server"
```

**Custom SSH Key Path:**
```bash
terraform apply -var="ssh_key_path=/path/to/my-key.pem"
```

### 4. Connect to EC2

```bash
# Get SSH command from output
terraform output ssh_connection_command

# Or connect directly
ssh -i ssh-key.pem ec2-user@$(terraform output -raw ec2_public_ip)
```

### 5. Connect to RDS (if created)

```bash
# SSH to EC2 first
ssh -i ssh-key.pem ec2-user@$(terraform output -raw ec2_public_ip)

# Install PostgreSQL client on EC2
sudo dnf install -y postgresql

# Connect to database
psql -h <rds-endpoint> -U postgres -d postgres
# Password from: terraform output rds_password
```

## Configuration

### Simple Variables (Root Level)

Only three variables are exposed at the root level for simplicity:

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `instance_name` | string | tpa-rhel-aws | Name for EC2 and project resources |
| `create_rds` | bool | false | Whether to create RDS PostgreSQL |
| `ssh_key_path` | string | ./ssh-key.pem | Path to save SSH private key |

**To customize:** Create a `terraform.tfvars` file or use `-var` flags.

### Advanced Configuration (Module Level)

For advanced configuration (VPC settings, instance types, RDS settings, etc.), see:
- `tpa_rhel_aws/variables.tf` - All available variables
- `tpa_rhel_aws/README.md` - Detailed module documentation

## What Gets Created

### EC2 Instance
- **Type:** m6i.2xlarge
- **AMI:** ami-0d8d3b1122e36c000 (RHEL)
- **Storage:** 100GB gp3 (encrypted)
- **Access:** SSH (port 22), HTTP (port 80), HTTPS (port 443)
- **Location:** Public subnet with internet access

### RDS PostgreSQL (Optional)
- **Engine:** PostgreSQL 17.2
- **Instance:** db.m7g.large
- **Storage:** 20GB gp3 (encrypted)
- **Location:** Private subnets (single-AZ for testing)
- **Access:** Only from EC2 instance

### Networking
- **VPC:** 10.0.0.0/16 (new VPC)
- **Public Subnet:** 10.0.1.0/24 (for EC2)
- **Private Subnets:** 10.0.10.0/24, 10.0.11.0/24 (for RDS)
- **Internet Gateway:** For public subnet
- **Security Groups:** EC2 (SSH/HTTP/HTTPS), RDS (PostgreSQL from EC2 only)

## Outputs

```bash
# View all outputs
terraform output

# Specific outputs
terraform output ec2_public_ip
terraform output ssh_connection_command
terraform output rds_endpoint
terraform output rds_password  # Sensitive
```

## Usage Examples

### Development Setup (EC2 Only)
```bash
terraform init
terraform apply
```

### Development Setup (EC2 + Database)
```bash
terraform apply -var="create_rds=true"
```

### Custom Configuration
```bash
terraform apply \
  -var="instance_name=my-app-server" \
  -var="create_rds=true" \
  -var="ssh_key_path=./keys/my-key.pem"
```

### Using terraform.tfvars
```bash
# Create terraform.tfvars
cat > terraform.tfvars <<EOF
instance_name = "production-server"
create_rds    = true
ssh_key_path  = "./production-key.pem"
EOF

# Apply
terraform apply
```

## Security Considerations

⚠️ **This is configured for testing/development**. For production use:

1. **Restrict SSH Access:** By default, SSH is open to 0.0.0.0/0
   - Edit `tpa_rhel_aws/variables.tf` and change `ssh_allowed_cidr` default
   - Or use AWS Systems Manager Session Manager (no SSH needed)

2. **Use Remote State:** Configure S3 backend for state management
   ```hcl
   terraform {
     backend "s3" {
       bucket = "my-terraform-state"
       key    = "tpa-rhel-aws/terraform.tfstate"
       region = "us-east-1"
       encrypt = true
     }
   }
   ```

3. **Enable RDS Protection:** See `tpa_rhel_aws/database.tf`
   - Set `skip_final_snapshot = false`
   - Enable `deletion_protection = true`
   - Configure backup retention

4. **Use Secrets Manager:** For RDS password management

See `tpa_rhel_aws/README.md` for detailed security recommendations.

## Project Structure

```
.
├── main.tf                      # Root module - invokes tpa_rhel_aws
├── variables.tf                 # Root variables (simple interface)
├── outputs.tf                   # Root outputs (pass-through)
├── terraform.tfvars.example     # Example configuration
├── .gitignore                   # Protect sensitive files
├── README.md                    # This file
└── tpa_rhel_aws/               # Infrastructure module
    ├── main.tf                  # Provider configuration
    ├── variables.tf             # All module variables
    ├── vpc.tf                   # VPC, subnets, networking
    ├── security_groups.tf       # Security group rules
    ├── ec2.tf                   # EC2 instance
    ├── ssh_key.tf               # SSH key generation
    ├── database.tf              # Optional RDS
    ├── outputs.tf               # Module outputs
    └── README.md                # Detailed module docs
```

## Cleanup

```bash
terraform destroy
```

**Note:** If RDS was created with `skip_final_snapshot = false`, you'll need to delete snapshots manually.

## Cost Estimate

Approximate monthly costs (us-east-1):
- **EC2 m6i.2xlarge:** ~$280/month
- **EBS 100GB gp3:** ~$8/month
- **RDS db.m7g.large:** ~$150/month (if enabled)
- **RDS storage 20GB:** ~$2.30/month (if enabled)

**Total:** ~$290/month (EC2 only) or ~$440/month (EC2 + RDS)

## Troubleshooting

### SSH Connection Refused
```bash
# Verify instance is running
terraform output ec2_instance_id
aws ec2 describe-instances --instance-ids $(terraform output -raw ec2_instance_id)

# Check your IP is allowed (default: 0.0.0.0/0)
curl -s ifconfig.me
```

### RDS Connection Timeout
RDS is in **private subnets** - you must connect from the EC2 instance, not your local machine.

### Permission Denied (SSH)
```bash
chmod 600 ssh-key.pem
```

## Support

- **Module Documentation:** See `tpa_rhel_aws/README.md`
- **AWS Provider Docs:** https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- **Terraform Docs:** https://www.terraform.io/docs

## License

Infrastructure as Code for TPA RHEL AWS project.
