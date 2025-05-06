# Security Group for Filebeat
resource "aws_security_group" "filebeat_sg" {
  name        = "filebeat-sg"
  description = "Security group for Filebeat"
  vpc_id      = module.vpc.vpc_id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  # ICMP
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "ICMP"
  }

  # All outbound traffic (needed for sending logs)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name        = "filebeat-sg"
    Environment = var.environment
  }
}

# EC2 Filebeat Instance
resource "aws_instance" "filebeat" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.filebeat_instance_type
  subnet_id     = var.create_vpc ? module.vpc.public_subnets[0] : var.existing_public_subnets[0]

  vpc_security_group_ids      = [aws_security_group.filebeat_sg.id]
  associate_public_ip_address = var.associate_public_ip_address
  key_name                    = aws_key_pair.elasticsearch_key[0].key_name

  root_block_device {
    volume_size = var.filebeat_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name           = var.filebeat_instance_name
    Environment    = var.environment
    ClusterName    = var.cluster_name
    Role           = "filebeat"
    AnsibleManaged = "true"
  }
}
