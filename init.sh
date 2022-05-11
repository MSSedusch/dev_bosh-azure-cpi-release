#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

azurecreds_choice=false
if [ -f .local/azurecreds.json ]; then
    echo "azurecreds.json already exists. Do you want to read the configuration parameter from this file? (Y/n): "
    read azurecreds_choice
    if [ "${azurecreds_choice}"  = "" ] || [ "${azurecreds_choice}"  = "y" ] || [ "${azurecreds_choice}"  = "Y" ]; then
        azurecreds_choice=true
        source ./env.sh
    fi    
fi

if [ "${azurecreds_choice}" == "false" ]; then

    echo "This script will ask for all neccessary parameters to deploy a BOSH director and to deploy a new VM using the CPI directly. If the Azure resources do not exist, they will be created."

    continue=true
    if [ -f ${SCRIPT_DIR}/.local/cpi.cfg ]; then
        echo "cpi.cfg already exists. Do you want to recreate the file? (y/N): "
        read continue_choice
        if [ "${continue_choice}"  = "" ] || [ "${continue_choice}"  = "n" ] || [ "${continue_choice}"  = "N" ]; then
            continue=false
        fi
    fi

    if [ ! "${continue}" == true ]; then
        exit 0
    fi

    if [ -f ${SCRIPT_DIR}/.local/cpi.cfg ]; then
        rm ${SCRIPT_DIR}/.local/cpi.cfg
    fi

    if [ ! -d .local ]; then
        mkdir .local
    fi

    echo "Enter the tenant id: "  
    read TENANT_ID

    echo "Enter the subscription id: "  
    read SUBSCRIPTION_ID

    echo "Enter the service principal id (client id/application id): "  
    read SPN_CLIENT_ID

    echo "Enter the service principal password: "  
    read -s SPN_CLIENT_SECRET

    echo "Enter the resource group name: "  
    read RESOURCE_GROUP

    echo "Enter the Azure Region: "  
    read AZURE_REGION

    echo "Enter the storage account name: "  
    read STORAGE_ACCOUNT

    echo "Enter the ssh public key: "  
    read SSH_PUBLIC_KEY

    defaultNSG="nsg"
    echo "Enter the name of the network security group (press enter for ${defaultNSG}):"
    read NETWORK_SECURITY_GROUP
    if [ "${NETWORK_SECURITY_GROUP}" == "" ]; then
        NETWORK_SECURITY_GROUP="${defaultNSG}"
    fi

    defaultVNET="bosh-vnet"
    echo "Enter the name of the virtual network name (press enter for ${defaultVNET}):"
    read VIRTUAL_NETWORK
    if [ "${VIRTUAL_NETWORK}" == "" ]; then
        VIRTUAL_NETWORK="${defaultVNET}"
    fi

    defaultSubnet="bosh"
    echo "Enter the name of the subnet (press enter for ${defaultSubnet}):"  
    read SUBNET_NAME
    if [ "${SUBNET_NAME}" == "" ]; then
        SUBNET_NAME="${defaultSubnet}"
    fi

    addressPrefixDefault="10.0.0.0/16"
    while true; do
        SUBNET_ADDRESS_PREFIX=""
        echo "Enter the address prefix of the vnet/subnet (press enter for ${addressPrefixDefault}):"  
        read SUBNET_ADDRESS_PREFIX

        if [ "${SUBNET_ADDRESS_PREFIX}" == "" ]; then
            SUBNET_ADDRESS_PREFIX="${addressPrefixDefault}"
        fi

        if [[ $SUBNET_ADDRESS_PREFIX =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]]; then # /[0-9][0-9]?$
            break
        fi

        echo "Please enter a correct address prefix."
    done

    [[ $SUBNET_ADDRESS_PREFIX =~ (^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)[0-9]{1,3}/[0-9]{1,2}$ ]];
    ipPrefix="${BASH_REMATCH[1]}"
    defaultGW="${ipPrefix}1"

    while true; do
        SUBNET_GATEWAY=""
        echo "Enter the IP address of the gateway in subnet ${SUBNET_NAME} (press enter for ${defaultGW}):"  
        read SUBNET_GATEWAY

        if [ "${SUBNET_GATEWAY}" == "" ]; then
            SUBNET_GATEWAY="${defaultGW}"
        fi

        if [[ $SUBNET_GATEWAY =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            break
        fi

        echo "Please enter a correct IP address for the subnet gateway."
    done

    defaultDirector="${ipPrefix}6"
    while true; do
        DIRECTOR_IP=""
        echo "Enter the IP address of the BOSH director in subnet ${SUBNET_NAME} (press enter for ${defaultDirector}):"  
        read DIRECTOR_IP

        if [ "${DIRECTOR_IP}" == "" ]; then
            DIRECTOR_IP="${defaultDirector}"
        fi

        if [[ $DIRECTOR_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            break
        fi

        echo "Please enter a correct IP address for the BOSH director."

    done

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

    cat >.local/azurecreds.json <<EOL
{
    "TENANT_ID":"${TENANT_ID}",
    "SUBSCRIPTION_ID":"${SUBSCRIPTION_ID}",
    "SPN_CLIENT_ID":"${SPN_CLIENT_ID}",
    "SPN_CLIENT_SECRET":"${SPN_CLIENT_SECRET}",
    "RESOURCE_GROUP":"${RESOURCE_GROUP}",
    "AZURE_REGION":"${AZURE_REGION}",
    "STORAGE_ACCOUNT":"${STORAGE_ACCOUNT}",
    "SSH_PUBLIC_KEY":"${SSH_PUBLIC_KEY}",
    "NETWORK_SECURITY_GROUP":"${NETWORK_SECURITY_GROUP}",
    "VIRTUAL_NETWORK":"${VIRTUAL_NETWORK}",
    "SUBNET_NAME":"${SUBNET_NAME}",
    "SUBNET_ADDRESS_PREFIX":"${SUBNET_ADDRESS_PREFIX}",
    "SUBNET_GATEWAY":"${SUBNET_GATEWAY}",
    "DIRECTOR_IP":"${DIRECTOR_IP}"
}
EOL

fi

envsubst < cpi.cfg.tmpl > .local/cpi.cfg

echo "Logging in to Azure"
az login --tenant "${TENANT_ID}" --service-principal --username "${SPN_CLIENT_ID}" --password "${SPN_CLIENT_SECRET}" > /dev/null
az account set --subscription "${SUBSCRIPTION_ID}"

echo "Checking resource group"
groupCheck=$(az group exists --name "${RESOURCE_GROUP}")
if [ ! "${groupCheck}" == "true" ]; then
    echo "Creating resource group ${RESOURCE_GROUP}"
    az group create --name "${RESOURCE_GROUP}" --location "${AZURE_REGION}" > /dev/null
fi

echo "Checking NSG"
existingNSG=$(az network nsg list --resource-group "${RESOURCE_GROUP}" | jq -r ".[] | select(.name==\"${NETWORK_SECURITY_GROUP}\") | .name")
if [ "${existingNSG}" == "" ]; then
    echo "Creating NSG"
    az network nsg create --resource-group "${RESOURCE_GROUP}" --name "${NETWORK_SECURITY_GROUP}" --location "${AZURE_REGION}" > /dev/null
fi

echo "Checking storage account"
existingStorageAccount=$(az storage account list --resource-group "${RESOURCE_GROUP}" | jq -r ".[] | select(.name==\"${STORAGE_ACCOUNT}\") | .name")
if [ "${existingStorageAccount}" == "" ]; then
    echo "Creating storage account"
    az storage account create --resource-group "${RESOURCE_GROUP}" --name "${STORAGE_ACCOUNT}" --location "${AZURE_REGION}" --sku Standard_LRS > /dev/null
fi

echo "Checking vnet"
existingVnet=$(az network vnet list --resource-group "${RESOURCE_GROUP}" | jq -r ".[] | select(.name==\"${VIRTUAL_NETWORK}\") | .name")
if [ "${existingVnet}" == "" ]; then
    echo "Creating virtual network"
    az network vnet create --resource-group "${RESOURCE_GROUP}" --name "${VIRTUAL_NETWORK}" --location "${AZURE_REGION}" --address-prefixes "${SUBNET_ADDRESS_PREFIX}" > /dev/null
fi

echo "Checking subnet"
existingSubnet=$(az network vnet subnet list --resource-group "${RESOURCE_GROUP}" --vnet-name "${VIRTUAL_NETWORK}" | jq -r ".[] | select(.name==\"${SUBNET_NAME}\") | .name")
if [ "${existingSubnet}" == "" ]; then
    echo "Creating subnet"
    az network vnet subnet create --resource-group "${RESOURCE_GROUP}" --vnet-name "${VIRTUAL_NETWORK}" --name "${SUBNET_NAME}" --address-prefixes "${SUBNET_ADDRESS_PREFIX}" > /dev/null
fi

echo "Done. Please checkout https://github.com/cloudfoundry/bosh-azure-cpi-release or your own fork to /workspace/dev_bosh-azure-cpi-release/bosh-azure-cpi-release now."

echo "Creating stemcell"
az storage container create --account-name "${STORAGE_ACCOUNT}" --name "cpi" --account-key "${storageKey}"  > /dev/null
wget https://storage.googleapis.com/bosh-core-stemcells/1.79/bosh-stemcell-1.79-azure-hyperv-ubuntu-bionic-go_agent.tgz -O .local/stemcell.tgz
mkdir .local/stemcell/
tar -xf .local/stemcell.tgz -C .local/stemcell/
tar -xf .local/stemcell/image -C .local/stemcell/
az storage blob upload --account-name "${STORAGE_ACCOUNT}" --account-key "${storageKey}" --container-name "cpi" --file .local/stemcell/root.vhd --name root.vhd
url=$(az storage blob url  --account-name "${STORAGE_ACCOUNT}" --account-key "${storageKey}" --container-name "cpi" --name root.vhd | jq -r '.')
az image create --name 8d149245-82d5-4c93-9d00-66e9e54bee88-P-westeurope --resource-group "${RESOURCE_GROUP}" --source "${url}" --location "${AZURE_REGION}" --os-type Linux --storage-sku Premium_LRS


$SHELL
