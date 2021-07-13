#!/bin/bash
set -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if [ -f "${SCRIPT_DIR}/.local/azurecreds.json" ]; then
    
    echo "Reading configuration values from cache..."

    TENANT_ID=$(cat .local/azurecreds.json | jq -r ".TENANT_ID")
    SUBSCRIPTION_ID=$(cat .local/azurecreds.json | jq -r ".SUBSCRIPTION_ID")
    SPN_CLIENT_ID=$(cat .local/azurecreds.json | jq -r ".SPN_CLIENT_ID")
    SPN_CLIENT_SECRET=$(cat .local/azurecreds.json | jq -r ".SPN_CLIENT_SECRET")
    RESOURCE_GROUP=$(cat .local/azurecreds.json | jq -r ".RESOURCE_GROUP")
    AZURE_REGION=$(cat .local/azurecreds.json | jq -r ".AZURE_REGION")
    STORAGE_ACCOUNT=$(cat .local/azurecreds.json | jq -r ".STORAGE_ACCOUNT")
    SSH_PUBLIC_KEY=$(cat .local/azurecreds.json | jq -r ".SSH_PUBLIC_KEY")
    NETWORK_SECURITY_GROUP=$(cat .local/azurecreds.json | jq -r ".NETWORK_SECURITY_GROUP")
    VIRTUAL_NETWORK=$(cat .local/azurecreds.json | jq -r ".VIRTUAL_NETWORK")
    SUBNET_NAME=$(cat .local/azurecreds.json | jq -r ".SUBNET_NAME")
    SUBNET_ADDRESS_PREFIX=$(cat .local/azurecreds.json | jq -r ".SUBNET_ADDRESS_PREFIX")
    SUBNET_GATEWAY=$(cat .local/azurecreds.json | jq -r ".SUBNET_GATEWAY")
    DIRECTOR_IP=$(cat .local/azurecreds.json | jq -r ".DIRECTOR_IP")

    export TENANT_ID
    export SUBSCRIPTION_ID
    export SPN_CLIENT_ID
    export SPN_CLIENT_SECRET
    export RESOURCE_GROUP
    export AZURE_REGION
    export STORAGE_ACCOUNT
    export SSH_PUBLIC_KEY
    export NETWORK_SECURITY_GROUP
    export VIRTUAL_NETWORK
    export SUBNET_NAME
    export SUBNET_ADDRESS_PREFIX
    export SUBNET_GATEWAY
    export DIRECTOR_IP

else
    echo "environment cache not found"
fi