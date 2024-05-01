#!/bin/bash

# Define variables for the resource group, storage account name, container name, and location.
# These variables will be used to create an Azure Storage Account and Blob Container to store Terraform state files.
RESOURCE_GROUP="jw-semantic-searcher-eus2-ops-rg"
STORAGE_ACCOUNT_NAME="jwssseruse2tfsa"  # Ensure this name is globally unique within Azure.
CONTAINER_NAME="terraformstate"
LOCATION="eastus2"

# Create a resource group in Azure with the specified name and location.
# Resource groups are containers that hold related resources for an Azure solution.
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create an Azure Storage Account within the specified resource group and location.
# The 'Standard_LRS' SKU indicates the use of Standard performance with Locally Redundant Storage.
# Enabling encryption for blob storage to ensure data is encrypted at rest.
az storage account create --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP \
    --location $LOCATION --sku Standard_LRS --encryption-services blob

# Retrieve the primary key of the storage account. This key is needed to perform operations on the storage account, such as creating a blob container.
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT_NAME \
    --query '[0].value' -o tsv)

# Create a blob container within the storage account. Blob containers are used to store blobs, such as images, text files, or Terraform state files.
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY

# Print a message indicating that the storage account and blob container have been successfully created.
# This setup is commonly used for storing Terraform state files in a remote backend configuration.
echo "Azure Storage Account and container created for Terraform backend."