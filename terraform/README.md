# Elasticsearch Cluster Infrastructure

This Terraform configuration provisions an Elasticsearch cluster on AWS EC2. The cluster will be automatically installed and configured with initial settings, including optional Kibana UI.

## Prerequisites

- AWS credentials with appropriate permissions
- Terraform installed (>= 1.0.0)
- Existing VPC with subnets (optional)

## Usage

1. Create your `terraform.tfvars` file in the root folder. You can refer to `terraform.tfvars.example` as a template, but make sure to replace all placeholder values with your actual configuration.

2. Configure the variables in `terraform.tfvars`, ensuring to provide:
   - AWS credentials
   - VPC and subnet IDs (or set create_vpc = true to create a new VPC)
   - SSH public key (optional)
   - Elasticsearch configuration options
   - Number of nodes in the cluster

3. Initialize and apply Terraform:
   ```
   terraform init
   terraform apply --auto-approve
   ```

**Note:** The terraform apply process will take approximately 5-7 minutes as it:
- Provisions the VPC (if specified)
- Provisions the EC2 instances
- Installs and configures Elasticsearch
- Sets up basic Elasticsearch cluster configuration
- Optionally installs and configures Kibana

## Important Notes

- If creating a new VPC, the process will set up public and private subnets with proper routing
- If using an existing VPC, ensure the subnets have proper internet connectivity
- After initial provisioning, you'll need to configure Elasticsearch indices and mappings
- Elasticsearch will be accessible on port 9200, and Kibana on port 5601 if enabled

## Security Considerations

- This setup is intended for development or testing purposes
- For production, consider:
  - Implementing proper security measures
  - Setting up proper TLS certificates
  - Implementing authentication mechanisms
  - Using a more robust storage configuration

## Input Variables

Please see the variables.tf file for detailed information about available configuration options.
