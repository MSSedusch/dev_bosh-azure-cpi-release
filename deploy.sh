#!/bin/bash
set -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if [ ! -d "${SCRIPT_DIR}/.local/bosh-deployment" ]; then
    git clone https://github.com/cloudfoundry/bosh-deployment "${SCRIPT_DIR}/.local/bosh-deployment"
fi

pushd "${SCRIPT_DIR}/.local/"

bosh create-env bosh-deployment/bosh.yml \
    --state=state.json \
    --vars-store=creds.yml \
    -o bosh-deployment/azure/cpi.yml \
    -v director_name=bosh-1 \
    -v internal_cidr=${SUBNET_ADDRESS_PREFIX} \
    -v internal_gw=${SUBNET_GATEWAY} \
    -v internal_ip=${DIRECTOR_IP} \
    -v vnet_name=${VIRTUAL_NETWORK} \
    -v subnet_name=${SUBNET_NAME} \
    -v subscription_id=${SUBSCRIPTION_ID} \
    -v tenant_id=${TENANT_ID} \
    -v client_id=${SPN_CLIENT_ID} \
    -v client_secret=${SPN_CLIENT_SECRET} \
    -v resource_group_name=${RESOURCE_GROUP} \
    -v storage_account_name=${STORAGE_ACCOUNT} \
    -v default_security_group=${NETWORK_SECURITY_GROUP}

popd

echo "Uploading stemcell ubuntu xenial..."
bosh -e bosh-1 upload-stemcell --sha1 b05d331dc762214388d6e7196bc235e9ac2e0b0a https://bosh-core-stemcells.s3-accelerate.amazonaws.com/621.125/bosh-stemcell-621.125-azure-hyperv-ubuntu-xenial-go_agent.tgz

$SHELL