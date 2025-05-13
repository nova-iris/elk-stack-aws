# Terraform Configuration for ELK Stack

This directory contains the Terraform configurations for deploying ELK Stack infrastructure in AWS. These configurations focus on creating the necessary cloud infrastructure components, which are then configured by Ansible playbooks in a separate step.

## Terraform Files Overview

```
terraform/
├── main.tf                 # Main configuration and resource dependencies
├── variables.tf            # Input variable declarations
├── outputs.tf              # Output value declarations
├── providers.tf            # Provider configuration
├── vpc.tf                  # VPC networking configuration 
├── elasticsearch.tf        # Elasticsearch instance configuration
├── logstash.tf             # Logstash instance configuration
├── filebeat.tf             # Filebeat instance configuration
├── s3_backup.tf            # S3 backup configuration
├── backup_variables.tf     # Backup-specific variables
├── data.tf                 # Data sources
├── terraform.tfvars        # Variable values (create from example file)
└── modules/                # Reusable modules
    ├── vpc/                # VPC module
    ├── ec2/                # EC2 instance module
    └── s3/                 # S3 module
```

## Manual Terraform Deployment

For DevOps engineers who want to directly control the Terraform deployment without using the deploy script, follow these steps:

### 1. Configure Variables

Create your `terraform.tfvars` file from the example:

```bash
cd /d/repos/nova-iris/elk-stack-setup/terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your configuration:

```bash
vi terraform.tfvars
```

Key variables to configure:

```hcl
# AWS Configuration
aws_region     = "us-east-1"     # e.g., us-east-1, us-west-2
aws_account_id = "123456789012"  # Your AWS Account ID
access_key     = "YOUR_ACCESS_KEY"
secret_key     = "YOUR_SECRET_KEY"

# VPC Configuration
create_vpc = true  # Set to false to use existing VPC
vpc_cidr   = "10.10.0.0/16"

# EC2 Configuration
instance_type  = "t3.2xlarge"  # Recommended for Elasticsearch
instance_count = 3             # Number of nodes in the Elasticsearch cluster
public_key     = "~/.ssh/id_rsa.pub"  # Path to your SSH public key
volume_size    = 100           # Recommended at least 100GB for Elasticsearch

# Elasticsearch Configuration
elasticsearch_version = "8.18.0"
cluster_name          = "elk-cluster"
enable_ui             = true  # Set to true to install Kibana alongside Elasticsearch

# Logstash Configuration
logstash_instance_type = "t3.xlarge"

# Filebeat Configuration
filebeat_instance_type = "t2.micro"

# Environment
environment = "dev"

# S3 Backup Configuration
es_use_s3_backups = true
```

### 2. Initialize and Apply

Initialize Terraform (only needed once or after module changes):

```bash
terraform init
```

Apply the configuration:

```bash
terraform plan -out=tfplan
terraform apply -auto-approve
```

### 3. Generate Ansible Inventory

After successful deployment, generate the Ansible inventory file:

```bash
cd /d/repos/nova-iris/elk-stack-setup/terraform/scripts
./generate-ansible-inventory.sh
```

This will create an inventory file at `../ansible/inventory/elk.ini` for use with Ansible.

## Important Configuration Options

### VPC Options

- **Create New VPC**: Set `create_vpc = true` to create a new VPC
- **Use Existing VPC**: Set `create_vpc = false` and provide `vpc_id` and subnet IDs

### Elasticsearch Cluster Configuration

- `instance_count`: Number of nodes in the Elasticsearch cluster
- `instance_type`: Instance type for Elasticsearch nodes
- `elasticsearch_version`: Version of Elasticsearch to deploy
- `cluster_name`: Name of the Elasticsearch cluster

### S3 Backup Configuration

- `es_use_s3_backups`: Enable/disable S3 backup infrastructure
- `s3_bucket_name`: Name for the S3 bucket (defaults to auto-generated name)
- `s3_backup_retention_days`: Number of days to retain backups

## Common Operations

### Apply Changes

To update the existing infrastructure:

```bash
cd /d/repos/nova-iris/elk-stack-setup/terraform
terraform plan -out=tfplan
terraform apply -auto-approve
```

### Refresh State

To sync Terraform state with actual AWS resources:

```bash
terraform refresh
```

### Examine State

```bash
# List all resources
terraform state list

# Show details of a specific resource
terraform state show aws_instance.elasticsearch_master[0]
```

### Target Specific Resources

Apply changes to specific resources:

```bash
terraform apply -target=module.vpc -auto-approve
```

### Destroy Infrastructure

To remove all infrastructure:

```bash
terraform destroy -auto-approve
```

To destroy specific components:

```bash
terraform destroy -target=aws_instance.logstash -auto-approve
```

## Remote State Management (Advanced)

To implement remote state storage in S3 with locking, add to `providers.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "elk-stack/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

## Performance Tuning

For larger Elasticsearch clusters or production environments, consider:

1. Adjusting instance types in `terraform.tfvars`:
   ```hcl
   instance_type = "r5.xlarge"
   ```

2. Enabling advanced monitoring:
   ```hcl
   enable_detailed_monitoring = true
   ```

3. Using dedicated EBS volumes for data:
   ```hcl
   volume_size = 200
   volume_type = "gp3"
   ```