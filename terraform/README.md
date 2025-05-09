# ELK Stack Terraform Infrastructure

This directory contains Terraform configurations to deploy a complete Elastic Stack (ELK) in AWS. The infrastructure consists of:

- Elasticsearch nodes (configurable cluster size)
- Logstash instance for data processing
- Filebeat instance for log collection
- VPC networking with public/private subnets (or option to use existing VPC)
- Security groups with proper port configurations
- Automatic generation of Ansible inventory for configuration management

## Prerequisites

Before you begin, ensure you have:

1. [Terraform](https://www.terraform.io/downloads.html) (v1.0.0 or higher) installed
2. AWS credentials configured on your system (via AWS CLI, environment variables, or credential files)
3. SSH key pair for accessing the instances

## Deployment Options

There are two ways to deploy the ELK stack:

1. **Terraform Only**: Use Terraform to provision the infrastructure only.
2. **Complete Deployment**: Use the `deploy-elk-stack.sh` script to provision infrastructure with Terraform and configure the ELK stack with Ansible in one step.

## Directory Structure

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
├── data.tf                 # Data sources
├── terraform.tfvars        # Variable values (create from example file)
├── terraform.tfvars.example # Example variable values
└── modules/                # Reusable modules
    ├── vpc/                # VPC module
    └── ec2/                # EC2 instance module
```

## Setup Instructions

### 1. Initialize Configuration

Clone this repository and navigate to the terraform directory:

```bash
cd /path/to/elk-stack-setup/terraform
```

Create your `terraform.tfvars` file from the example:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` to customize your deployment. Important settings include:

- AWS region
- VPC configuration (create new or use existing)
- Instance types and sizes
- Cluster configuration
- SSH key location
- Environment name

### 2. Initialize Terraform

Initialize the Terraform workspace:

```bash
terraform init
```

This will download the required providers and modules.

### 3. Preview Changes

Generate an execution plan to preview the changes:

```bash
terraform plan -out=tfplan
```

Review the changes to ensure they match your expectations.

### 4. Apply Configuration

Apply the Terraform configuration to create the infrastructure:

```bash
terraform apply tfplan
```

Or directly apply without a saved plan:

```bash
terraform apply
```

The infrastructure creation will take several minutes. Once complete, Terraform will output connection information for your instances.

### 5. Access Your Instances

After deployment, you can access your instances using SSH:

```bash
ssh -i /path/to/key.pem ubuntu@<instance_public_ip>
```

The public IPs are provided in the Terraform outputs.

## Running with deploy-elk-stack.sh

For a complete deployment that includes both infrastructure provisioning and configuration, you can use the `deploy-elk-stack.sh` script from the root directory:

```bash
cd /path/to/elk-stack-setup/
./deploy-elk-stack.sh
```

This script will:

1. Run `terraform init` and `terraform apply` to provision the AWS infrastructure
2. Generate the Ansible inventory file
3. Run Ansible playbooks to install and configure the ELK stack components
4. Verify the deployment

### Script Options

The `deploy-elk-stack.sh` script accepts several options:

```bash
./deploy-elk-stack.sh [-t] [-a] [-h]
```

- `-t`: Run Terraform only (no Ansible configuration)
- `-a`: Run Ansible only (assumes infrastructure exists)
- `-h`: Show help message

Example for Terraform-only deployment:
```bash
./deploy-elk-stack.sh -t
```

## Common Operations

### Updating Infrastructure

To make changes to the infrastructure:

1. Edit `terraform.tfvars` with your desired changes
2. Run `terraform plan -out=tfplan` to see what would change
3. Apply the changes with `terraform apply tfplan`

### Refreshing State

To update the Terraform state with the current real infrastructure:

```bash
terraform refresh
```

### Showing Current Resources

To see the managed resources and their attributes:

```bash
terraform state list
terraform state show <resource_name>
```

## Destroying Infrastructure

To destroy all resources created by this Terraform configuration:

```bash
terraform destroy
```

You'll be asked to confirm before proceeding. This action is irreversible and will delete all created resources.

For a more targeted approach, you can destroy specific resources:

```bash
terraform destroy -target=module.filebeat
```

## Additional Information

- The infrastructure is designed to work with the Ansible playbooks in the `../ansible` directory
- After Terraform successfully deploys, an Ansible inventory file is automatically generated at `../ansible/inventory/elk.ini`
- For a complete deployment, run the `../deploy-elk-stack.sh` script which combines both Terraform and Ansible steps

## Troubleshooting

Common issues:

1. **AWS credentials not found**: Ensure your AWS credentials are properly configured
2. **Resources not being created**: Check for limits in your AWS account
3. **VPC errors**: If using existing VPC/subnets, verify their IDs and availability 
4. **SSH connection issues**: Verify security group rules and key pairs

For more detailed troubleshooting, check the Terraform logs by setting the environment variable:

```bash
export TF_LOG=DEBUG
terraform apply
```

## Contributing

When adding new features or making changes to this Terraform code:

1. Create a new branch for your changes
2. Test thoroughly before merging
3. Update this README with any new variables or important information
4. Consider adding examples for common use cases
