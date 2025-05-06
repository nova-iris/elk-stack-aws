terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider removed - using provider from root module

module "ami_ubuntu_24_04_latest" {
  source = "github.com/andreswebs/terraform-aws-ami-ubuntu"
}

locals {
  ami_id = module.ami_ubuntu_24_04_latest.ami_id

  # Handle tilde expansion for home directory in public key path
  public_key_path = var.public_key != "" ? (
    replace(var.public_key, "~/", pathexpand("~/"))
  ) : ""
}

resource "aws_security_group" "vault_sg" {
  name        = var.security_group_name
  description = "Allow SSH and Vault API access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8201
    to_port     = 8201
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
    Project     = "Vault"
  }
}

resource "aws_key_pair" "ec2_key" {
  count      = var.public_key != "" ? 1 : 0
  key_name   = "${var.instance_name}-key"
  public_key = file(local.public_key_path)
}

module "vault_server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 4.3.0"

  name = var.instance_name

  ami                    = local.ami_id
  instance_type          = var.instance_type
  key_name               = var.public_key != "" ? aws_key_pair.ec2_key[0].key_name : null
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.vault_sg.id]

  associate_public_ip_address = var.associate_public_ip_address

  root_block_device = [
    {
      volume_size           = var.volume_size
      volume_type           = "gp2"
      delete_on_termination = false
      # Removing volume tagging to avoid SCP restrictions
    }
  ]

  # Simply use the user data passed from outside
  user_data = var.user_data

  tags = {
    Environment = var.environment
    Project     = "Vault"
  }
}

resource "aws_ec2_instance_state" "this" {
  instance_id = module.vault_server.id
  state       = var.instance_state
}
