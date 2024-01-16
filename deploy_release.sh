#!/bin/bash
set -e
concourseUsername=bosh

az group create --name "${RESOURCE_GROUP_RELEASE}" --location "${AZURE_REGION}"
#az role assignment create --role Contributor --assignee "${SPN_CLIENT_ID}" --scope "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP_RELEASE}"
az deployment group create --name inital --resource-group "${RESOURCE_GROUP_RELEASE}" --template-uri https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/application-workloads/concourse/concourse-ci/azuredeploy.json -p jumpboxSshKeyData="${SSH_PUBLIC_KEY}" -p jumpboxVmName=jb -p jumpboxUsername="bosh" -p concourseUsername="${concourseUsername}" -p concoursePassword="${BOSH_USER_PASSWORD}" -p tenantID="${TENANT_ID}" -p clientID="${SPN_CLIENT_ID}" -p clientSecret="${SPN_CLIENT_SECRET}"
jbIP=$(az network public-ip show -g "${RESOURCE_GROUP_RELEASE}" -n jb-devbox | jq -r '.ipAddress')
sshCmd=$(az deployment group show --name inital --resource-group "${RESOURCE_GROUP_RELEASE}" | jq -r '.properties.outputs.sshDevBox.value')
concourseEndpoint=$(az deployment group show --name inital --resource-group "${RESOURCE_GROUP_RELEASE}" | jq -r '.properties.outputs.concourseEndpoint.value')
$sshCmd -C ~/deploy_bosh.sh
$sshCmd -C ~/deploy_concourse.sh
fly -t azure login -c "${concourseEndpoint}" -u "${concourseUsername}" -p "${BOSH_USER_PASSWORD}"
accountKey=$(az storage account keys list --account-name "${STORAGE_ACCOUNT}" | jq -r '.[0].value')
az storage container create --account-name "${STORAGE_ACCOUNT}" -n artifacts --account-key "${accountKey}"
az storage container create --account-name "${STORAGE_ACCOUNT}" -n tfstate  --account-key "${accountKey}"
#TODO create /workspaces/dev_bosh-azure-cpi-release/.local/credentials-develop.yml
fly -t azure set-pipeline -p bosh-azure-cpi-develop -c /workspaces/dev_bosh-azure-cpi-release/bosh-azure-cpi-release/ci/develop/pipeline-develop.yml -l /workspaces/dev_bosh-azure-cpi-release/.local/credentials-develop.yml
fly -t azure unpause-pipeline -p bosh-azure-cpi-develop