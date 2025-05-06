# Filebeat instance using the enhanced EC2 module
module "filebeat" {
  source = "./modules/ec2"

  # VPC/Network Configuration
  vpc_id                      = module.vpc.vpc_id
  subnet_id                   = var.create_vpc ? module.vpc.public_subnets[0] : var.existing_public_subnets[0]
  associate_public_ip_address = var.associate_public_ip_address

  # Instance Configuration
  instance_name         = var.filebeat_instance_name
  instance_type         = var.filebeat_instance_type
  volume_size           = var.filebeat_volume_size
  root_volume_type      = "gp3"
  delete_on_termination = false
  public_key            = var.public_key

  # Security Configuration - Custom ports for Filebeat
  security_group_name          = "filebeat-sg-${var.environment}"
  enable_default_ingress_rules = true # Enable SSH/HTTP/HTTPS

  # Add ICMP as custom ingress rule
  custom_ingress_rules = [
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
    Role           = "filebeat"
    AnsibleManaged = "true"
  }
  environment = var.environment

  # User data script for Filebeat installation and configuration
  # user_data = templatefile("${path.module}/scripts/filebeat.sh.tftpl", {
  #   elasticsearch_host = module.elasticsearch.private_ips[0]
  #   environment        = var.environment
  # })
}
