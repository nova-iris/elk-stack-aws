# ELK Stack Setup

This repository contains automation scripts for deploying and configuring a complete Elastic Stack (ELK) in AWS using Terraform for infrastructure provisioning and Ansible for configuration management.

## Architecture Overview

The deployed ELK Stack consists of:

- **Elasticsearch**: Distributed search and analytics engine (configurable cluster size)
- **Logstash**: Server-side data processing pipeline
- **Kibana**: Data visualization dashboard for Elasticsearch
- **Filebeat**: Lightweight log shipper for forwarding logs

## Directory Structure

```
elk-stack-setup/
├── deploy-elk-stack.sh     # Main deployment script
├── ansible/                # Ansible playbooks and roles for ELK configuration
│   ├── install-elk.yml     # Main playbook for ELK installation
│   ├── inventory/          # Host inventory files
│   └── roles/              # Component-specific configuration roles
├── terraform/              # Terraform configurations for AWS infrastructure
│   ├── modules/            # Reusable Terraform modules
│   ├── scripts/            # Provisioning scripts
│   └── templates/          # Template files
└── README.md               # This file
```

## Prerequisites

Before beginning deployment, ensure you have:

1. **AWS Account**: Valid AWS account with permissions to create resources
2. **Terraform**: Version 1.0.0 or higher installed
3. **Ansible**: Version 2.9 or higher installed
4. **SSH Key Pair**: For accessing the instances
5. **AWS CLI** (optional): Configured with valid credentials
6. **jq**: For JSON parsing in scripts

## Deployment Options

You have two options for deploying the ELK Stack:

### Option 1: Complete Deployment Script (Recommended)

Use the included `deploy-elk-stack.sh` script to handle both infrastructure provisioning and configuration:

```bash
cd /path/to/elk-stack-setup
```

**Important**: Before running the deployment script, create your `terraform.tfvars` file:

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edit terraform.tfvars with your AWS credentials and configuration settings
```

Then run the deployment script:

```bash
./deploy-elk-stack.sh
```

This script will:
1. Check prerequisites
2. Validate AWS credentials
3. Deploy infrastructure with Terraform
4. Configure ELK Stack with Ansible
5. Display access information

#### Script Options

```bash
./deploy-elk-stack.sh [-t component1,component2] [-a] [-h]
```

- `-t`: Deploy specific components (elasticsearch,kibana,logstash,filebeat)
- `-a`: Run only Ansible configuration (skip Terraform)
- `-h`: Show help message

Examples:

```bash
# Deploy only Elasticsearch and Kibana components
./deploy-elk-stack.sh -t elasticsearch,kibana

# Run only Ansible configuration (if infrastructure exists)
./deploy-elk-stack.sh -a
```

### Option 2: Manual Deployment

If you prefer to run Terraform and Ansible separately:

#### 1. Terraform Infrastructure

```bash
cd /path/to/elk-stack-setup/terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your AWS credentials and settings
terraform init
terraform plan -out=tfplan
terraform apply -auto-approve
```

#### 2. Ansible Configuration

After Terraform creates the infrastructure and generates the inventory file:

```bash
cd /path/to/elk-stack-setup/ansible
ansible-playbook install-elk.yml
```

To deploy specific components:

```bash
ansible-playbook install-elk.yml -t elasticsearch,kibana
```

## Important Notes

- A new Elasticsearch password is generated after every Ansible run. Check the final output console for credentials.
- Ansible playbooks can be re-run with specific tags for targeted configuration updates.
- After the first run with enrollment for data nodes, re-running Ansible for enrollment may cause failures in data nodes as they are already enrolled (these will be ignored).

## Accessing Your ELK Stack

After successful deployment, access information will be displayed:

- **Elasticsearch**: https://<elasticsearch_master_ip>:9200
- **Kibana**: http://<elasticsearch_master_ip>:5601
- **Default Username**: elastic
- **Password**: Generated and shown in deployment output (also stored on Elasticsearch master node)

To retrieve the Elasticsearch password:

```bash
ssh ubuntu@<elasticsearch_master_ip> -i /path/to/your/key 'sudo cat /etc/elasticsearch/elastic_credentials.txt'
```

## S3 Backup Configuration

The stack supports configuring S3 buckets for Elasticsearch snapshots and backups:

1. By default, S3 bucket creation is enabled (`es_use_s3_backups = true`)
2. The S3 bucket is configured with lifecycle policies for efficient storage management
3. IAM roles and policies are automatically created and attached to Elasticsearch instances

To disable S3 backup infrastructure, set `es_use_s3_backups = false` in your `terraform.tfvars` file.

### Configuring Elasticsearch for S3 Repository

After the infrastructure is deployed, you need to register the S3 repository in Elasticsearch:

```bash
# SSH into the master Elasticsearch node
ssh ubuntu@<elasticsearch_master_ip>

# Register the S3 repository (replace with your actual values)
curl -X PUT "localhost:9200/_snapshot/s3_repository" -H "Content-Type: application/json" -d'
{
  "type": "s3",
  "settings": {
    "bucket": "<your-bucket-name>",
    "region": "<aws-region>"
  }
}'
```

## Updating the Stack

To make changes to your ELK Stack configuration:

1. Edit Terraform variables in `/path/to/elk-stack-setup/terraform/terraform.tfvars`
2. Run the deployment script or Terraform directly to apply infrastructure changes
3. Run specific Ansible playbooks using tags if needed

## Destroying the Environment

To destroy all created resources:

```bash
cd /path/to/elk-stack-setup/terraform
terraform destroy -auto-approve
```

## Troubleshooting

Common issues:

1. **SSH Connection Issues**: Verify security group rules and key pairs
2. **Elasticsearch Cluster Formation**: Check network settings and discovery configuration
3. **Ansible Errors**: Verify the inventory file was properly generated
4. **AWS Resource Limits**: Ensure your account has sufficient capacity

For detailed logs:

```bash
export TF_LOG=DEBUG
terraform apply -auto-approve
```

## Contributing

When contributing to this project:

1. Create a new branch for your changes
2. Test thoroughly before merging
3. Update documentation with any new features or important information