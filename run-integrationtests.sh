#!/bin/bash
set -e

source env.sh

export AZURE_ENVIRONMENT=AzureCloud
export AZURE_TENANT_ID=$TENANT_ID
export AZURE_SUBSCRIPTION_ID=$SUBSCRIPTION_ID
export AZURE_CLIENT_ID=$SPN_CLIENT_ID
export AZURE_CLIENT_SECRET=$SPN_CLIENT_SECRET
export AZURE_CERTIFICATE="empty"
export IS_HEAVY_STEMCELL=true
# RESOURCE_GROUP
# AZURE_REGION
# STORAGE_ACCOUNT
# SSH_PUBLIC_KEY
# NETWORK_SECURITY_GROUP
# VIRTUAL_NETWORK
# SUBNET_NAME
# SUBNET_ADDRESS_PREFIX
# SUBNET_GATEWAY
# DIRECTOR_IP
# BOSH_USER_PASSWORD
# RESOURCE_GROUP_RELEASE

mkdir .local/stemcell
# TODO: copy stemcell.tgz to .local/stemcell
mkdir .local/environment
cat > .local/environment/metadata << EOF
{
    "storage_account_name": "${STORAGE_ACCOUNT}",
    "default_resource_group_name": "${RESOURCE_GROUP}",
    "location": "${AZURE_REGION}",
    "additional_resource_group_name": "additional_resource_group_name",
    "extra_storage_account_name": "extra_storage_account_name",
    "vnet_name": "${VIRTUAL_NETWORK}",
    "subnet_1_name": "${SUBNET_NAME}",
    "subnet_2_name": "bosh-subnet2",
    "default_security_group": "${NETWORK_SECURITY_GROUP}",
    "public_ip_in_default_rg": "public_ip_in_default_rg",
    "public_ip_in_additional_rg": "public_ip_in_additional_rg",
    "asg_name": "asg_name",
    "application_gateway_name": "application_gateway_name",
    "default_user_assigned_identity_name": "default_user_assigned_identity_name",
    "user_assigned_identity_name": "user_assigned_identity_name"
}
EOF

pushd .local > /dev/null
    ./bosh-cpi-src/ci/tasks/upload-stemcell.sh
    ./bosh-cpi-src/ci/tasks/run-integration.sh
popd