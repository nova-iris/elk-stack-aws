# Elasticsearch instances using the enhanced EC2 module
module "elasticsearch" {
  source = "./modules/ec2"

  # VPC/Network Configuration
  vpc_id                      = module.vpc.vpc_id
  subnet_id                   = var.create_vpc ? module.vpc.public_subnets[0] : var.existing_public_subnets[0]
  associate_public_ip_address = var.associate_public_ip_address

  # Instance Configuration
  instance_name         = var.instance_name
  instance_type         = var.instance_type
  instance_count        = var.instance_count
  volume_size           = var.volume_size
  root_volume_type      = "gp2"
  delete_on_termination = false
  public_key            = var.public_key

  # IAM Instance Profile for S3 backup access
  iam_instance_profile = var.es_use_s3_backups ? aws_iam_instance_profile.elasticsearch_profile[0].name : null

  # Security Configuration - Custom ports for Elasticsearch
  security_group_name          = "elasticsearch-sg-${var.environment}"
  enable_default_ingress_rules = true # Enable SSH/HTTP/HTTPS

  # Add custom rules for Elasticsearch
  custom_ingress_rules = [
    {
      from_port   = 9200
      to_port     = 9200
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Elasticsearch REST API"
    },
    {
      from_port   = 9300
      to_port     = 9300
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Elasticsearch inter-node communication"
    },
    {
      from_port   = 5601
      to_port     = 5601
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Kibana UI"
    },
    {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "ICMP"
    }
  ]

  # Tags
  additional_tags = {
    ClusterName    = var.cluster_name
    Role           = "elasticsearch"
    AnsibleManaged = "true"
  }
  environment = var.environment

  # User data script for Elasticsearch installation and configuration
  # user_data = templatefile("${path.module}/scripts/elasticsearch.sh.tftpl", {
  #   cluster_name          = var.cluster_name
  #   node_name             = "${var.instance_name}-1"
  #   elasticsearch_version = var.elasticsearch_version
  #   enable_ui             = var.enable_ui
  #   heap_size             = "512m"
  #   all_nodes_ips         = join(", ", [for i in range(var.instance_count) : "\"${var.instance_name}-${i + 1}\""])
  #   initial_masters       = join(", ", [for i in range(var.instance_count) : "\"${var.instance_name}-${i + 1}\""])
  # })
}

# This key pair is kept for backward compatibility with other resources that might reference it
# resource "aws_key_pair" "elasticsearch_key" {
#   count      = var.public_key != "" ? 1 : 0
#   key_name   = "elasticsearch-key-${var.environment}"
#   public_key = file(var.public_key)
# }
