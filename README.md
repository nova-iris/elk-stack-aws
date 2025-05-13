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
4. Automated daily snapshots are configured to run at midnight

To disable S3 backup infrastructure, set `es_use_s3_backups = false` in your `terraform.tfvars` file.

### Automated Backup Configuration

The ELK Stack is configured with the following automated backup settings:

1. **Repository Plugin**: The S3 repository plugin is automatically installed on all Elasticsearch nodes
2. **AWS Credentials**: IAM instance profiles are used for secure, no-credential access to S3
3. **Snapshot Schedule**: Snapshots are taken daily at midnight
4. **Snapshot Contents**: Each snapshot includes all indices and the global cluster state
5. **Retention Policy**: Snapshots are retained for 30 days, with a minimum of 5 and maximum of 50 snapshots

### Manual Snapshot Management

You can manually manage snapshots using the Elasticsearch API:

```bash
# SSH into the master Elasticsearch node
ssh ubuntu@<elasticsearch_master_ip>

# Create a manual snapshot
curl -X PUT "http://localhost:9200/_snapshot/s3_repository/manual_snapshot?wait_for_completion=true" \
     -H "Content-Type: application/json" -u elastic:YOUR_PASSWORD

# List all snapshots
curl -X GET "http://localhost:9200/_snapshot/s3_repository/_all" -u elastic:YOUR_PASSWORD

# Restore a snapshot
curl -X POST "http://localhost:9200/_snapshot/s3_repository/snapshot_name/_restore" \
     -H "Content-Type: application/json" -u elastic:YOUR_PASSWORD
```

### Customizing Backup Settings

To modify the backup configuration (schedule, retention, etc.):

1. Edit `/d/repos/nova-iris/elk-stack-setup/ansible/roles/elasticsearch_s3_backup/defaults/main.yml` 
2. Re-run the deployment script with the Ansible-only option:
   ```bash
   ./deploy-elk-stack.sh -a
   ```

### Running Only S3 Backup Configuration

If you want to run only the S3 backup configuration without deploying other components:

#### Option 1: Using Tag with install-elk.yml

```bash
cd /d/repos/nova-iris/elk-stack-setup/ansible
ansible-playbook install-elk.yml -t s3_backup
```

#### Option 2: Using Dedicated S3 Backup Playbook

```bash
cd /d/repos/nova-iris/elk-stack-setup/ansible
ansible-playbook s3-backup.yml
```

#### Option 3: Using deploy-elk-stack.sh with Tag

```bash
cd /d/repos/nova-iris/elk-stack-setup
./deploy-elk-stack.sh -a -t s3_backup
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