#!/bin/bash
set -e

RESOURCE_GROUP="focusflow-rg"
VM_NAME="focusflow-vm"
LOCATION="southafricanorth"

az group create --name $RESOURCE_GROUP --location $LOCATION

az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image Ubuntu2204 \
  --size Standard_B2s_v2 \
  --admin-username azureuser \
  --generate-ssh-keys

az vm open-port --resource-group $RESOURCE_GROUP --name $VM_NAME --port 80

echo "Done. Public IP:"
az vm show -d --resource-group $RESOURCE_GROUP --name $VM_NAME --query publicIps -o tsv