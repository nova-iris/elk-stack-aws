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
  ami_id = var.ami_id != "" ? var.ami_id : module.ami_ubuntu_24_04_latest.ami_id

  # Handle tilde expansion for home directory in public key path
  public_key_path = var.public_key != "" ? (
    replace(var.public_key, "~/", pathexpand("~/"))
  ) : ""

  # Merge default and additional tags
  tags = merge(
    {
      Environment = var.environment
      Project     = "Infrastructure"
      Name        = var.instance_name
    },
    var.additional_tags
  )
}

resource "aws_security_group" "instance_sg" {
  name        = var.security_group_name
  description = "Security group for ${var.instance_name}"
  vpc_id      = var.vpc_id

  # Default SSH ingress rule
  dynamic "ingress" {
    for_each = var.enable_default_ingress_rules ? [1] : []
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "SSH access"
    }
  }

  # Default HTTP ingress rule
  dynamic "ingress" {
    for_each = var.enable_default_ingress_rules ? [1] : []
    content {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP access"
    }
  }

  # Default HTTPS ingress rule
  dynamic "ingress" {
    for_each = var.enable_default_ingress_rules ? [1] : []
    content {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS access"
    }
  }

  # Custom ingress rules
  dynamic "ingress" {
    for_each = var.custom_ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = local.tags
}

resource "aws_key_pair" "ec2_key" {
  count      = var.public_key != "" ? 1 : 0
  key_name   = "${var.instance_name}-key"
  public_key = file(local.public_key_path)
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 4.3.0"

  name  = var.instance_name
  count = var.instance_count

  ami                    = local.ami_id
  instance_type          = var.instance_type
  key_name               = var.public_key != "" ? aws_key_pair.ec2_key[0].key_name : null
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  iam_instance_profile        = var.iam_instance_profile
  associate_public_ip_address = var.associate_public_ip_address

  root_block_device = [
    {
      volume_size           = var.volume_size
      volume_type           = var.root_volume_type
      delete_on_termination = var.delete_on_termination
    }
  ]

  # Use the user data passed from outside
  user_data = var.user_data

  tags = local.tags
}

resource "aws_ec2_instance_state" "this" {
  count       = var.instance_count
  instance_id = module.ec2_instance[count.index].id
  state       = var.instance_state
}
