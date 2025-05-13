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

# Generate Ansible inventory file
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tftpl", {
    elasticsearch_instances = [
      for i in range(module.elasticsearch.instance_count) : {
        public_ip  = module.elasticsearch.public_ips[i],
        private_ip = module.elasticsearch.private_ips[i],
        id         = module.elasticsearch.instance_ids[i],
        tags = {
          Name           = "${var.instance_name}-${i + 1}",
          Environment    = var.environment,
          ClusterName    = var.cluster_name,
          Role           = "elasticsearch",
          AnsibleManaged = "true"
        }
      }
    ],
    logstash_instance = {
      public_ip  = module.logstash.public_ip,
      private_ip = module.logstash.private_ip,
      id         = module.logstash.instance_id,
      tags = {
        Name           = var.logstash_instance_name,
        Environment    = var.environment,
        ClusterName    = var.cluster_name,
        Role           = "logstash",
        AnsibleManaged = "true"
      }
    },
    filebeat_instance = {
      public_ip  = module.filebeat.public_ip,
      private_ip = module.filebeat.private_ip,
      id         = module.filebeat.instance_id,
      tags = {
        Name           = var.filebeat_instance_name,
        Environment    = var.environment,
        ClusterName    = var.cluster_name,
        Role           = "filebeat",
        AnsibleManaged = "true"
      }
    },
    cluster_name                = var.cluster_name,
    elasticsearch_version       = var.elasticsearch_version,
    enable_ui                   = var.enable_ui,
    es_use_s3_backups           = var.es_use_s3_backups,
    environment                 = var.environment,
    aws_region                  = var.aws_region,
    elasticsearch_backup_bucket = var.es_use_s3_backups ? module.elasticsearch_backup[0].bucket_id : ""
  })
  filename = "${path.module}/../ansible/inventory/elk.ini"

  depends_on = [
    module.elasticsearch,
    module.logstash,
    module.filebeat
  ]
}
