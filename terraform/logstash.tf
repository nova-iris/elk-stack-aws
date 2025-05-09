# Logstash instance using the enhanced EC2 module
module "logstash" {
  source = "./modules/ec2"

  # VPC/Network Configuration
  vpc_id                      = module.vpc.vpc_id
  subnet_id                   = var.create_vpc ? module.vpc.public_subnets[0] : var.existing_public_subnets[0]
  associate_public_ip_address = var.associate_public_ip_address

  # Instance Configuration
  instance_name         = var.logstash_instance_name
  instance_type         = var.logstash_instance_type
  volume_size           = var.logstash_volume_size
  root_volume_type      = "gp2"
  delete_on_termination = false
  public_key            = var.public_key

  # Security Configuration - Custom ports for Logstash
  security_group_name          = "logstash-sg-${var.environment}"
  enable_default_ingress_rules = true # Enable SSH/HTTP/HTTPS

  # Add custom rules for Logstash
  custom_ingress_rules = [
    {
      from_port   = 5044
      to_port     = 5044
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Logstash Beats input"
    },
    {
      from_port   = 5000
      to_port     = 5000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Logstash TCP input"
    },
    {
      from_port   = 5000
      to_port     = 5000
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Logstash UDP input"
    },
    {
      from_port   = 514
      to_port     = 514
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Syslog TCP"
    },
    {
      from_port   = 514
      to_port     = 514
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Syslog UDP"
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Logstash HTTP input"
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
    Role           = "logstash"
    AnsibleManaged = "true"
  }
  environment = var.environment

  # User data script for Logstash installation and configuration
  #   user_data = templatefile("${path.module}/scripts/logstash.sh.tftpl", {
  #     elasticsearch_host = module.elasticsearch.private_ips[0]
  #     environment        = var.environment
  #   })
}
