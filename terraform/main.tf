terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  # VPC specific variables
  environment              = var.environment
  create_vpc               = var.create_vpc
  vpc_id                   = var.vpc_id
  vpc_cidr                 = var.vpc_cidr
  existing_public_subnets  = var.existing_public_subnets
  existing_private_subnets = var.existing_private_subnets
}

# Security Group for Elasticsearch Cluster
resource "aws_security_group" "elasticsearch_sg" {
  name        = "elasticsearch-sg"
  description = "Security group for Elasticsearch cluster"
  vpc_id      = module.vpc.vpc_id

  # Elasticsearch REST API
  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Elasticsearch REST API"
  }

  # Elasticsearch inter-node communication
  ingress {
    from_port   = 9300
    to_port     = 9300
    protocol    = "tcp"
    self        = true
    description = "Elasticsearch inter-node communication"
  }

  # Kibana UI
  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Kibana UI"
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
    Name        = "elasticsearch-sg"
    Environment = var.environment
  }
}

# EC2 Elasticsearch Instances
resource "aws_instance" "elasticsearch" {
  count         = var.instance_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = var.create_vpc ? module.vpc.public_subnets[count.index % length(module.vpc.public_subnets)] : var.existing_public_subnets[count.index % length(var.existing_public_subnets)]

  vpc_security_group_ids      = [aws_security_group.elasticsearch_sg.id]
  associate_public_ip_address = var.associate_public_ip_address
  key_name                    = aws_key_pair.elasticsearch_key[0].key_name

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name           = "${var.instance_name}-${count.index + 1}"
    Environment    = var.environment
    ClusterName    = var.cluster_name
    Role           = "elasticsearch"
    AnsibleManaged = "true"
  }
}

# SSH Key Pair
resource "aws_key_pair" "elasticsearch_key" {
  count      = var.public_key != "" ? 1 : 0
  key_name   = "elasticsearch-key-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  public_key = file(var.public_key)
}

# Latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
