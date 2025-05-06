#!/bin/bash
#
# Script to extract Elasticsearch credentials from logs
# Compatible with Elasticsearch 8.x

# ANSI color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Searching for Elasticsearch credentials...${NC}"

# First try to read from saved credentials file
if [ -f /etc/elasticsearch/elastic_credentials.txt ]; then
    echo -e "${GREEN}Found stored credentials:${NC}"
    cat /etc/elasticsearch/elastic_credentials.txt
    exit 0
fi

# If file doesn't exist, search the logs
PASSWORD=$(grep -A 20 "Security autoconfiguration information" /var/log/elasticsearch/elasticsearch*.log | 
           grep -m 1 "The generated password for the elastic built-in superuser is" | 
           awk -F ': ' '{print $2}')

if [ -n "$PASSWORD" ]; then
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${GREEN}ELASTICSEARCH & KIBANA LOGIN CREDENTIALS${NC}"
    echo -e "${GREEN}=========================================${NC}"
    echo -e "Username: ${YELLOW}elastic${NC}"
    echo -e "Password: ${YELLOW}$PASSWORD${NC}"
    echo 
    echo "You can use these credentials to log into both Elasticsearch and Kibana."
    echo -e "${GREEN}=========================================${NC}"
    
    # Save credentials to file for future reference
    cat > /etc/elasticsearch/elastic_credentials.txt << EOF
Elasticsearch Credentials
------------------------
Username: elastic
Password: $PASSWORD

These credentials can be used to log into both Elasticsearch and Kibana.
Please store this information securely.
EOF
    chmod 600 /etc/elasticsearch/elastic_credentials.txt
    echo "Credentials saved to /etc/elasticsearch/elastic_credentials.txt"
else
    echo "Could not find Elasticsearch password in logs."
    echo "If Elasticsearch has been running for a while, the password might no longer be in the logs."
    echo "Check if the password is saved in /etc/elasticsearch/elastic_credentials.txt on the master node."
fi