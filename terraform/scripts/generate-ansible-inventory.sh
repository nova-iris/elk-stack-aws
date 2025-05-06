#!/bin/bash

# Get Terraform outputs
echo "Retrieving Terraform outputs..."
ELASTICSEARCH_IPS=$(terraform output -json elasticsearch_public_ips | jq -r '.[]')

# Create inventory file
INVENTORY_FILE="../ansible/inventory/elasticsearch.ini"
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

# Write all nodes section
cat >> ${INVENTORY_FILE} << EOF

[elasticsearch:children]
elasticsearch_master
elasticsearch_data

[elasticsearch:vars]
ansible_ssh_private_key_file=~/.ssh/id_ed25519
elasticsearch_cluster_name=${CLUSTER_NAME:-elk-cluster}
elasticsearch_version=${ES_VERSION:-7.10.2}
enable_kibana=${ENABLE_UI:-true}
EOF

echo "Ansible inventory generated at ${INVENTORY_FILE}"
echo "Use with: ansible-playbook -i ${INVENTORY_FILE} elasticsearch-setup.yml"