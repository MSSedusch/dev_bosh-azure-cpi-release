#!/bin/bash
set -e

cd /workspaces/dev_bosh-azure-cpi-release/.local/bosh-azure-cpi-release

# https://stackoverflow.com/questions/5143795/how-can-i-check-in-a-bash-script-if-my-local-git-repository-has-changes
CHANGED=$(git diff-index --name-only HEAD --)
if [ -n "$CHANGED" ]; then
    git add .
    git commit -m "build commit"
fi

cpi_dev_version=$(date +%Y.%m.%d.%H%M%S)
containerName=cpi
cpiFileName="bosh-azure-cpi-release-${cpi_dev_version}.tgz"
cpiFile="/workspaces/dev_bosh-azure-cpi-release/.local/${cpiFileName}"
bosh create-release --name=bosh-azure-cpi --version=${cpi_dev_version} --tarball=${cpiFile}

echo "Logging in to Azure"
az login --tenant "${TENANT_ID}" --service-principal --username "${SPN_CLIENT_ID}" --password "${SPN_CLIENT_SECRET}" > /dev/null
az account set --subscription "${SUBSCRIPTION_ID}" > /dev/null
storageKey=$(az storage account keys list --account-name "${STORAGE_ACCOUNT}" --resource-group "${RESOURCE_GROUP}" | jq -r ".[0].value")
az storage container create --account-name "${STORAGE_ACCOUNT}" --name "cpi" --account-key "${storageKey}" --public-access blob  > /dev/null
az storage blob upload --account-name "${STORAGE_ACCOUNT}" --file "${cpiFile}" \
    --name "${cpiFileName}" --container-name "cpi" --account-key "${storageKey}" > /dev/null

url=$(az storage blob url --account-name "${STORAGE_ACCOUNT}" --container-name "${containerName}" --account-key "${storageKey}")
sha1=$(sha1sum "${cpiFile}")
echo "File URL is ${url}"
echo "File SHA1 is ${sha1}"
echo "Adapt /workspaces/dev_bosh-azure-cpi-release/.local/bosh-deployment/azure/cpi.yml to use the CPI"

$SHELL
