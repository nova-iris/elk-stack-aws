#!/bin/bash

# =========================================================
# ELK Stack Deployment Script
# =========================================================
# This script automates the deployment of ELK Stack using 
# Terraform for infrastructure and Ansible for configuration
# Usage: ./deploy-elk-stack.sh [-t tag1,tag2] [-a] [-h]
#   -t: Component tags to deploy (elasticsearch,kibana,logstash,filebeat)
#   -a: Run only Ansible configuration (skip Terraform)
#   -h: Show help message
# =========================================================

set -e # Exit on error

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="${SCRIPT_DIR}/terraform"
ANSIBLE_DIR="${SCRIPT_DIR}/ansible"

# Default values
COMPONENT_TAGS=""
ANSIBLE_ONLY=false
SHOW_HELP=false

# Parse command-line options
while getopts "t:ah" opt; do
  case $opt in
    t)
      COMPONENT_TAGS="$OPTARG"
      ;;
    a)
      ANSIBLE_ONLY=true
      ;;
    h)
      SHOW_HELP=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Display help message if requested
if [ "$SHOW_HELP" = true ]; then
    echo "Usage: ./deploy-elk-stack.sh [-t tag1,tag2] [-a] [-h]"
    echo "  -t: Component tags to deploy (elasticsearch,kibana,logstash,filebeat)"
    echo "  -a: Run only Ansible configuration (skip Terraform)"
    echo "  -h: Show this help message"
    exit 0
fi

# Function to display colored messages
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Validate component tags if provided
validate_tags() {
    if [ -n "$COMPONENT_TAGS" ]; then
        log_info "Validating component tags: $COMPONENT_TAGS"
        VALID_TAGS=true
        
        # Check each tag is valid
        IFS=',' read -ra TAGS <<< "$COMPONENT_TAGS"
        for tag in "${TAGS[@]}"; do
            if [[ ! "$tag" =~ ^(elasticsearch|kibana|logstash|filebeat)$ ]]; then
                log_error "Invalid component tag: $tag"
                VALID_TAGS=false
            fi
        done
        
        if [ "$VALID_TAGS" = false ]; then
            log_error "Valid component tags are: elasticsearch, kibana, logstash, filebeat"
            exit 1
        fi
    fi
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if ansible is installed
    if ! command -v ansible &> /dev/null; then
        log_error "Ansible is not installed. Please install Ansible and try again."
        exit 1
    else
        ANSIBLE_VERSION=$(ansible --version | head -n 1)
        log_info "Found $ANSIBLE_VERSION"
    fi
    
    # Check for terraform only if not in ansible-only mode
    if [ "$ANSIBLE_ONLY" = false ]; then
        # Check if terraform is installed
        if ! command -v terraform &> /dev/null; then
            log_error "Terraform is not installed. Please install Terraform and try again."
            exit 1
        else
            TERRAFORM_VERSION=$(terraform --version | head -n 1)
            log_info "Found $TERRAFORM_VERSION"
        fi
        
        # Check if jq is installed (required for parsing terraform output)
        if ! command -v jq &> /dev/null; then
            log_error "jq is not installed. Please install jq and try again."
            exit 1
        else
            log_info "Found jq for JSON parsing"
        fi
        
        # Check if AWS CLI is installed
        if ! command -v aws &> /dev/null; then
            log_error "AWS CLI is not installed. It's required for AWS credential validation."
            exit 1
        else
            AWS_VERSION=$(aws --version)
            log_info "Found $AWS_VERSION"
        fi
    fi
    
    log_success "All required tools are installed."
}

# Prepare terraform.tfvars file or check for AWS credentials
prepare_terraform_vars() {
    # Skip if in ansible-only mode
    if [ "$ANSIBLE_ONLY" = true ]; then
        return 0
    fi
    
    log_info "Checking Terraform variables and AWS credentials..."
    
    # Check if terraform.tfvars exists (condition 1)
    if [ -f "${TERRAFORM_DIR}/terraform.tfvars" ]; then
        log_info "Found terraform.tfvars file."
        
        # Extract AWS credentials from terraform.tfvars
        ACCESS_KEY=$(grep -E "^access_key\s*=" "${TERRAFORM_DIR}/terraform.tfvars" | sed 's/^access_key\s*=\s*"\(.*\)"/\1/')
        SECRET_KEY=$(grep -E "^secret_key\s*=" "${TERRAFORM_DIR}/terraform.tfvars" | sed 's/^secret_key\s*=\s*"\(.*\)"/\1/')
        REGION=$(grep -E "^aws_region\s*=" "${TERRAFORM_DIR}/terraform.tfvars" | sed 's/^aws_region\s*=\s*"\(.*\)"/\1/')
        
        # Check if we could extract credentials
        if [ -z "$ACCESS_KEY" ] || [ -z "$SECRET_KEY" ]; then
            log_warning "Could not extract AWS credentials from terraform.tfvars."
            log_info "Checking if AWS CLI is configured with valid credentials..."
            
            # Validate AWS credentials using AWS CLI
            if ! aws sts get-caller-identity &>/dev/null; then
                log_error "No valid AWS credentials found in terraform.tfvars or AWS CLI configuration."
                log_error "Please ensure terraform.tfvars contains valid 'access_key' and 'secret_key' entries,"
                log_error "or configure AWS CLI with valid credentials (aws configure)."
                exit 1
            else
                CALLER_IDENTITY=$(aws sts get-caller-identity --query "Arn" --output text)
                log_success "Using AWS CLI credentials. Identity: $CALLER_IDENTITY"
            fi
        else
            # Set environment variables temporarily for validation
            log_info "Validating AWS credentials from terraform.tfvars..."
            export AWS_ACCESS_KEY_ID="$ACCESS_KEY"
            export AWS_SECRET_ACCESS_KEY="$SECRET_KEY"
            [ -n "$REGION" ] && export AWS_REGION="$REGION"
            
            if ! aws sts get-caller-identity &>/dev/null; then
                log_error "AWS credentials in terraform.tfvars are invalid."
                exit 1
            else
                CALLER_IDENTITY=$(aws sts get-caller-identity --query "Arn" --output text)
                log_success "AWS credentials from terraform.tfvars validated. Identity: $CALLER_IDENTITY"
            fi
        fi
    else
        log_warning "terraform.tfvars not found. Checking for AWS environment variables..."
        
        # Check if AWS environment variables are set (condition 2)
        if [[ -n "${AWS_ACCESS_KEY_ID}" && -n "${AWS_SECRET_ACCESS_KEY}" ]]; then
            log_info "Found AWS environment variables."
            
            # Validate AWS credentials from environment variables
            if ! aws sts get-caller-identity &>/dev/null; then
                log_error "AWS environment variables are invalid."
                exit 1
            else
                CALLER_IDENTITY=$(aws sts get-caller-identity --query "Arn" --output text)
                log_success "AWS environment credentials validated. Identity: $CALLER_IDENTITY"
            fi
        else
            # Neither condition 1 nor 2 is met
            log_error "No valid AWS credentials configuration found."
            log_error "Please either:"
            log_error "  1. Create a terraform.tfvars file in ${TERRAFORM_DIR} with valid AWS credentials"
            log_error "  2. Set AWS environment variables (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)"
            exit 1
        fi
    fi
    
    log_success "Terraform variables and AWS credentials ready."
}

# Deploy with Terraform
deploy_terraform() {
    # Skip if in ansible-only mode
    if [ "$ANSIBLE_ONLY" = true ]; then
        return 0
    fi
    
    log_info "Starting Terraform deployment..."
    
    cd "${TERRAFORM_DIR}"
    
    log_info "Initializing Terraform..."
    terraform init
    
    log_info "Validating Terraform configuration..."
    terraform validate
    
    log_info "Creating and applying Terraform plan..."
    terraform plan -out=tfplan
    terraform apply -auto-approve tfplan
    
    log_success "Terraform infrastructure deployed successfully!"
    
    # Extract S3 configuration as environment variables for Ansible
    cd "${TERRAFORM_DIR}"
    export ES_USE_S3_BACKUPS=$(terraform output -raw es_use_s3_backups 2>/dev/null || echo "true")
    export S3_BUCKET_NAME=$(terraform output -raw elasticsearch_backup_bucket 2>/dev/null || echo "")
    export AWS_REGION=$(terraform output -raw aws_region 2>/dev/null || echo "us-east-1")
    cd "${SCRIPT_DIR}"
    
    log_info "S3 Backup Configuration: Enabled=${ES_USE_S3_BACKUPS}, Bucket=${S3_BUCKET_NAME}, Region=${AWS_REGION}"
    
    # Verify inventory file was generated
    if [ -f "${ANSIBLE_DIR}/inventory/elk.ini" ]; then
        log_success "Ansible inventory generated by Terraform."
    else
        log_error "Ansible inventory not found at ${ANSIBLE_DIR}/inventory/elk.ini"
        exit 1
    fi
    
    cd "${SCRIPT_DIR}"
}

# Verify Ansible inventory
verify_ansible_inventory() {
    log_info "Verifying Ansible inventory..."
    
    if [ ! -f "${ANSIBLE_DIR}/inventory/elk.ini" ]; then
        log_error "Ansible inventory file not found at ${ANSIBLE_DIR}/inventory/elk.ini"
        log_error "Cannot proceed with Ansible configuration."
        exit 1
    fi
    
    if [ ! -s "${ANSIBLE_DIR}/inventory/elk.ini" ]; then
        log_error "Ansible inventory file is empty."
        log_error "Cannot proceed with Ansible configuration."
        exit 1
    fi
    
    # Check if inventory contains required host groups
    if ! grep -q "\[elasticsearch\]" "${ANSIBLE_DIR}/inventory/elk.ini" && \
       ! grep -q "\[elasticsearch_master\]" "${ANSIBLE_DIR}/inventory/elk.ini"; then
        log_error "Ansible inventory does not contain any Elasticsearch hosts."
        log_error "Cannot proceed with Ansible configuration."
        exit 1
    fi
    
    log_success "Ansible inventory verified."
}

# Configure with Ansible
configure_elk_stack() {
    log_info "Starting ELK Stack configuration with Ansible..."
    
    cd "${ANSIBLE_DIR}"
    
    # Verify the inventory file
    verify_ansible_inventory
    
    # Test connectivity to hosts
    log_info "Testing connection to hosts..."
    ansible all -m ping
    
    if [ $? -ne 0 ]; then
        log_error "Failed to connect to some hosts. Please check your SSH keys and network connectivity."
        log_info "You may need to wait a bit longer for instances to initialize."
        read -p "Do you want to continue anyway? (y/n): " continue_anyway
        if [[ ! $continue_anyway == "y" && ! $continue_anyway == "Y" ]]; then
            return 1
        fi
    fi
    
    # Check for tags passed as script arguments
    if [ -n "$COMPONENT_TAGS" ]; then
        log_info "Deploying selected components: $COMPONENT_TAGS"
        ansible-playbook install-elk.yml -t "$COMPONENT_TAGS"
    else
        log_info "Deploying all components..."
        ansible-playbook install-elk.yml
    fi
    
    log_success "ELK Stack configured successfully!"
    cd "${SCRIPT_DIR}"
}

# Display ELK Stack access information
display_access_info() {
    log_info "Displaying ELK Stack access information..."
    
    cd "${ANSIBLE_DIR}"
    
    # Extract elasticsearch master IP
    ES_MASTER_IP=$(grep -A1 '\[elasticsearch_master\]' "${ANSIBLE_DIR}/inventory/elk.ini" | tail -n 1 | awk '{print $1}')
    
    if [ -z "$ES_MASTER_IP" ]; then
        log_error "Could not determine Elasticsearch master IP."
        return 1
    fi
    
    # Display access information
    echo -e "\n${BLUE}=================================================${NC}"
    echo -e "${BLUE}           ELK STACK ACCESS INFORMATION           ${NC}"
    echo -e "${BLUE}=================================================${NC}"
    echo -e "${GREEN}Elasticsearch endpoint:${NC} https://$ES_MASTER_IP:9200"
    echo -e "${GREEN}Kibana URL:${NC} http://$ES_MASTER_IP:5601"
    echo -e "${GREEN}Default username:${NC} elastic"
    echo -e "${YELLOW}Password:${NC} Check on the Elasticsearch master node at /etc/elasticsearch/elastic_credentials.txt"
    echo -e "${BLUE}=================================================${NC}\n"
    
    echo "To retrieve the elastic user password, run:"
    echo -e "${YELLOW}ssh ubuntu@$ES_MASTER_IP -i ~/.ssh/id_ed25519 'sudo cat /etc/elasticsearch/elastic_credentials.txt'${NC}\n"
    
    cd "${SCRIPT_DIR}"
}

# Main function
main() {
    echo -e "\n${BLUE}=================================================${NC}"
    echo -e "${BLUE}    ELK Stack Deployment Automation Script${NC}"
    echo -e "${BLUE}=================================================${NC}\n"
    
    # Validate component tags if provided
    validate_tags
    
    # Check prerequisites based on mode
    check_prerequisites
    
    if [ "$ANSIBLE_ONLY" = true ]; then
        log_info "Running in Ansible-only mode. Skipping Terraform deployment."
        verify_ansible_inventory
        configure_elk_stack
        display_access_info
        
        log_success "ELK Stack configuration completed successfully!"
    else
        prepare_terraform_vars
        
        read -p "Do you want to proceed with deployment? (y/n): " proceed
        
        if [[ $proceed == "y" || $proceed == "Y" ]]; then
            deploy_terraform
            
            # Wait for instances to fully initialize
            log_info "Waiting for instances to initialize (60 seconds)..."
            sleep 60
            
            configure_elk_stack
            display_access_info
            
            log_success "ELK Stack deployment completed successfully!"
        else
            log_warning "Deployment cancelled by user."
        fi
    fi
    
    echo -e "\n${BLUE}=================================================${NC}"
    echo -e "${BLUE}              Deployment Complete${NC}"
    echo -e "${BLUE}=================================================${NC}\n"
}

# Run the main function
main "$@"