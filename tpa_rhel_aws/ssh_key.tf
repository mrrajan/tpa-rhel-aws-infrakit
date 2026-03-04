# Generate SSH Key Pair
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS Key Pair
resource "aws_key_pair" "ec2_key" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.ec2_key.public_key_openssh

  tags = {
    Name = "${var.project_name}-key"
  }
}

# Save Private Key Locally
resource "local_file" "private_key" {
  content         = tls_private_key.ec2_key.private_key_pem
  filename        = var.ssh_key_path != "" ? var.ssh_key_path : "${path.module}/ssh-key-${var.project_name}.pem"
  file_permission = "0600"
}
