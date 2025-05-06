# VPC Module

This module handles the VPC infrastructure for the Vault deployment.

## Features

- Option to create a new VPC or use an existing one
- Creates public and private subnets in multiple availability zones when creating a new VPC
- Sets up NAT gateway for private subnet internet access
- Configures proper routing for public and private subnets

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_vpc | Whether to create a new VPC | bool | true | no |
| vpc_id | Existing VPC ID (if create_vpc = false) | string | "" | no |
| vpc_cidr | CIDR block for the VPC | string | 10.0.0.0/16 | no |
| environment | Deployment environment | string | dev | no |
| existing_public_subnets | List of existing public subnet IDs | list(string) | [] | no |
| existing_private_subnets | List of existing private subnet IDs | list(string) | [] | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC (new or existing) |
| public_subnets | List of public subnet IDs |
| private_subnets | List of private subnet IDs |
