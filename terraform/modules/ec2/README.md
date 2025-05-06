# EC2 Module

This module provides a flexible and reusable approach for deploying EC2 instances in AWS, suitable for various applications like Elasticsearch, Logstash, Filebeat, and other components in an ELK stack.

## Features

- Provisions one or more EC2 instances with configurable options
- Uses Ubuntu 24.04 by default, but supports custom AMIs
- Flexible security group configuration with default (SSH/HTTP/HTTPS) and custom ingress rules
- Configurable root volume size and type
- Supports instance IAM profiles for AWS service integration
- Optional public IP assignment
- Custom user data support for instance configuration
- Additional tagging options

## Usage Example

```hcl
# Create a basic EC2 instance
module "elasticsearch_instance" {
  source = "../modules/ec2"
  
  vpc_id         = module.vpc.vpc_id
  subnet_id      = module.vpc.private_subnets[0]
  instance_name  = "elasticsearch-server"
  instance_type  = "t3.large"
  volume_size    = 50
  
  custom_ingress_rules = [
    {
      from_port   = 9200
      to_port     = 9200
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
      description = "Elasticsearch API"
    },
    {
      from_port   = 9300
      to_port     = 9300
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
      description = "Elasticsearch cluster communication"
    }
  ]
  
  user_data = templatefile("${path.module}/scripts/elasticsearch.sh.tftpl", {
    cluster_name = "elk-cluster"
    node_name    = "elasticsearch-server"
  })
  
  additional_tags = {
    Service = "Elasticsearch"
    Role    = "Data"
  }
}

# Create multiple Logstash instances
module "logstash_instances" {
  source = "../modules/ec2"
  
  vpc_id         = module.vpc.vpc_id
  subnet_id      = module.vpc.private_subnets[0]
  instance_name  = "logstash"
  instance_count = 2
  instance_type  = "t3.medium"
  
  custom_ingress_rules = [
    {
      from_port   = 5044
      to_port     = 5044
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
      description = "Logstash Beats input"
    }
  ]
  
  user_data = templatefile("${path.module}/scripts/logstash.sh.tftpl", {
    elasticsearch_host = module.elasticsearch_instance.private_ip
  })
  
  additional_tags = {
    Service = "Logstash"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_id | VPC ID where EC2 instance(s) will be deployed | string | - | yes |
| subnet_id | Subnet ID where EC2 instance(s) will be deployed | string | - | yes |
| instance_name | Name prefix of the EC2 instance(s) | string | "ec2-instance" | no |
| instance_type | EC2 instance type | string | "t3.medium" | no |
| instance_count | Number of instances to create | number | 1 | no |
| use_num_suffix | Whether to append a numerical suffix to instance names | bool | true | no |
| ami_id | Custom AMI ID (defaults to latest Ubuntu 24.04) | string | "" | no |
| public_key | Path to SSH public key file | string | "" | no |
| associate_public_ip_address | Whether to assign a public IP address | bool | false | no |
| user_data | User data script content | string | "" | no |
| volume_size | Size of the root volume in GB | number | 20 | no |
| root_volume_type | Type of the root volume | string | "gp2" | no |
| delete_on_termination | Whether to delete the root volume on termination | bool | false | no |
| security_group_name | Name for the security group | string | "ec2-sg" | no |
| enable_default_ingress_rules | Whether to enable default ingress rules | bool | true | no |
| custom_ingress_rules | List of custom ingress rules | list(object) | [] | no |
| additional_tags | Additional tags to add to resources | map(string) | {} | no |
| environment | Deployment environment | string | "dev" | no |
| instance_state | EC2 instance state after provisioning | string | "running" | no |
| iam_instance_profile | IAM Instance Profile name | string | null | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_ids | List of IDs of all EC2 instances |
| instance_id | ID of the first EC2 instance (for backward compatibility) |
| private_ips | List of private IP addresses of all EC2 instances |
| private_ip | Private IP address of the first EC2 instance |
| public_ips | List of public IP addresses (if enabled) |
| public_ip | Public IP address of the first instance |
| security_group_id | ID of the security group |
| security_group_name | Name of the security group |
| instance_arns | List of ARNs of all EC2 instances |
| primary_network_interface_ids | List of primary network interface IDs |
