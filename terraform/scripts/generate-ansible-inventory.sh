#!/bin/bash

# Get Terraform outputs
echo "Retrieving Terraform outputs..."
ELASTICSEARCH_IPS=$(terraform output -json elasticsearch_public_ips | jq -r '.[]')
LOGSTASH_IP=$(terraform output -json logstash_public_ip | jq -r '.')
FILEBEAT_IP=$(terraform output -json filebeat_public_ip | jq -r '.')

# Create inventory file
INVENTORY_FILE="../ansible/inventory/elk.ini"
mkdir -p "../ansible/inventory"

# Write inventory header
cat > ${INVENTORY_FILE} << EOF
# Ansible inventory generated from Terraform outputs
# Generated on $(date)

[elasticsearch_master]
EOF

# Add first node as master
echo "${ELASTICSEARCH_IPS}" | head -1 | awk '{print $1 " elasticsearch_node_role=master ansible_user=ubuntu"}' >> ${INVENTORY_FILE}

# Write data nodes section
cat >> ${INVENTORY_FILE} << EOF

[elasticsearch_data]
EOF

# Add all nodes as data nodes
echo "${ELASTICSEARCH_IPS}" | awk '{print $1 " elasticsearch_node_role=data ansible_user=ubuntu"}' >> ${INVENTORY_FILE}

# Write logstash section
cat >> ${INVENTORY_FILE} << EOF

[logstash]
${LOGSTASH_IP} ansible_user=ubuntu
EOF

# Write filebeat section
cat >> ${INVENTORY_FILE} << EOF

[filebeat]
${FILEBEAT_IP} ansible_user=ubuntu
EOF

# Write all nodes section
cat >> ${INVENTORY_FILE} << EOF

[elasticsearch:children]
elasticsearch_master
elasticsearch_data

[elk:children]
elasticsearch
logstash
filebeat

[elasticsearch:vars]
ansible_ssh_private_key_file=~/.ssh/id_ed25519
elasticsearch_cluster_name=${CLUSTER_NAME:-elk-cluster}
elasticsearch_version=${ES_VERSION:-7.10.2}
enable_kibana=${ENABLE_UI:-true}

[logstash:vars]
ansible_ssh_private_key_file=~/.ssh/id_ed25519
elasticsearch_hosts=${ELASTICSEARCH_IPS}

[filebeat:vars]
ansible_ssh_private_key_file=~/.ssh/id_ed25519
logstash_host=${LOGSTASH_IP}
EOF

echo "Ansible inventory generated at ${INVENTORY_FILE}"
echo "Use with: ansible-playbook -i ${INVENTORY_FILE} elk-setup.yml"