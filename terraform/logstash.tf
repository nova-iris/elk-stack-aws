# Security Group for Logstash
resource "aws_security_group" "logstash_sg" {
  name        = "logstash-sg"
  description = "Security group for Logstash"
  vpc_id      = module.vpc.vpc_id

  # Beats input
  ingress {
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Logstash Beats input"
  }

  # TCP input
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Logstash TCP input"
  }

  # UDP input
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Logstash UDP input"
  }

  # Syslog TCP
  ingress {
    from_port   = 514
    to_port     = 514
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Syslog TCP"
  }

  # Syslog UDP
  ingress {
    from_port   = 514
    to_port     = 514
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Syslog UDP"
  }

  # HTTP input
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Logstash HTTP input"
  }

  # SSH
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

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name        = "logstash-sg"
    Environment = var.environment
  }
}

# EC2 Logstash Instance
resource "aws_instance" "logstash" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.logstash_instance_type
  subnet_id     = var.create_vpc ? module.vpc.public_subnets[0] : var.existing_public_subnets[0]

  vpc_security_group_ids      = [aws_security_group.logstash_sg.id, aws_security_group.elasticsearch_sg.id]
  associate_public_ip_address = var.associate_public_ip_address
  key_name                    = aws_key_pair.elasticsearch_key[0].key_name

  root_block_device {
    volume_size = var.logstash_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name           = var.logstash_instance_name
    Environment    = var.environment
    ClusterName    = var.cluster_name
    Role           = "logstash"
    AnsibleManaged = "true"
  }
}
