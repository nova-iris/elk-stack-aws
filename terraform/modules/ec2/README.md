# EC2 Vault Module

This module handles the deployment of EC2 instances, which can be used for Vault or other applications.

## Features

- Provisions an EC2 instance
- Sets up appropriate security groups for Vault (ports 8200 and 8201)
- Configures optional SSH access with public key
- Accepts prepared user data from outside the module
- Supports optional ALB configuration for load balancing

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_id | VPC ID where the EC2 instance will be deployed | string | - | yes |
| subnet_id | Subnet ID where the EC2 instance will be deployed | string | - | yes |
| instance_name | Name of the EC2 instance | string | vault-server | no |
| instance_type | EC2 instance type | string | t3.medium | no |
| public_key | Path to SSH public key file | string | "" | no |
| associate_public_ip_address | Whether to assign a public IP address | bool | false | no |
| user_data | User data script content, prepared outside the module | string | "" | no |
| volume_size | Size of the root volume in GB | number | 20 | no |
| create_alb | Whether to create an ALB | bool | false | no |
| public_subnet_ids | List of subnet IDs for ALB (if create_alb=true) | list(string) | [] | no |

## Outputs

| Name | Description |
|------|-------------|
| vault_instance_id | ID of the EC2 instance |
| vault_private_ip | Private IP address of the EC2 instance |
| vault_public_ip | Public IP address (if enabled) |
| vault_endpoint | Endpoint URL for accessing Vault |
