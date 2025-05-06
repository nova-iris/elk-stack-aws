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
    elasticsearch_instances = aws_instance.elasticsearch,
    logstash_instance       = aws_instance.logstash,
    filebeat_instance       = aws_instance.filebeat,
    cluster_name            = var.cluster_name,
    elasticsearch_version   = var.elasticsearch_version,
    enable_ui               = var.enable_ui
  })
  filename = "${path.module}/../ansible/inventory/elk.ini"

  depends_on = [
    aws_instance.elasticsearch,
    aws_instance.logstash,
    aws_instance.filebeat
  ]
}
