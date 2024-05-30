#!/bin/bash

# Define variables for the resource group, storage account name, container name, and location.
# These variables will be used to create an Azure Storage Account and Blob Container to store Terraform state files.
RESOURCE_GROUP="jw-semantic-searcher-eus2-ops-rg"
STORAGE_ACCOUNT_NAME="jwssseruse2tfsa"  # Ensure this name is globally unique within Azure.
CONTAINER_NAME="terraformstate"
LOCATION="eastus2"
GITHUB_REPO="Cobollatin/jw-semantic-searcher" # The format is: user/repo

# Create a resource group in Azure with the specified name and location.
# Resource groups are containers that hold related resources for an Azure solution.
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create an Azure Storage Account within the specified resource group and location.
# The 'Standard_LRS' SKU indicates the use of Standard performance with Locally Redundant Storage.
# Enabling encryption for blob storage to ensure data is encrypted at rest.
az storage account create --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP \
    --location $LOCATION --sku Standard_LRS --encryption-services blob --min-tls-version TLS1_2

# Retrieve the primary key of the storage account. This key is needed to perform operations on the storage account, such as creating a blob container.
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT_NAME \
    --query '[0].value' -o tsv)

# Create a blob container within the storage account. Blob containers are used to store blobs, such as images, text files, or Terraform state files.
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY

# Array for github_runner_allow_out_bound_github_actions_ip_addressess
github_runner_allow_out_bound_github_actions_ip_addressess=(
  "4.175.114.51/32"
  "20.102.35.120/32"
  "4.175.114.43/32"
  "20.72.125.48/32"
  "20.19.5.100/32"
  "20.7.92.46/32"
  "20.232.252.48/32"
  "52.186.44.51/32"
  "20.22.98.201/32"
  "20.246.184.240/32"
  "20.96.133.71/32"
  "20.253.2.203/32"
  "20.102.39.220/32"
  "20.81.127.181/32"
  "52.148.30.208/32"
  "20.14.42.190/32"
  "20.85.159.192/32"
  "52.224.205.173/32"
  "20.118.176.156/32"
  "20.236.207.188/32"
  "20.242.161.191/32"
  "20.166.216.139/32"
  "20.253.126.26/32"
  "52.152.245.137/32"
  "40.118.236.116/32"
  "20.185.75.138/32"
  "20.96.226.211/32"
  "52.167.78.33/32"
  "20.105.13.142/32"
  "20.253.95.3/32"
  "20.221.96.90/32"
  "51.138.235.85/32"
  "52.186.47.208/32"
  "20.7.220.66/32"
  "20.75.4.210/32"
  "20.120.75.171/32"
  "20.98.183.48/32"
  "20.84.200.15/32"
  "20.14.235.135/32"
  "20.10.226.54/32"
  "20.22.166.15/32"
  "20.65.21.88/32"
  "20.102.36.236/32"
  "20.124.56.57/32"
  "20.94.100.174/32"
  "20.102.166.33/32"
  "20.31.193.160/32"
  "20.232.77.7/32"
  "20.102.38.122/32"
  "20.102.39.57/32"
  "20.85.108.33/32"
  "40.88.240.168/32"
  "20.69.187.19/32"
  "20.246.192.124/32"
  "20.4.161.108/32"
  "20.22.22.84/32"
  "20.1.250.47/32"
  "20.237.33.78/32"
  "20.242.179.206/32"
  "40.88.239.133/32"
  "20.121.247.125/32"
  "20.106.107.180/32"
  "20.22.118.40/32"
  "20.15.240.48/32"
  "20.84.218.150/32"
)

# Array for github_runner_allow_out_bound_github_ip_addressess
github_runner_allow_out_bound_github_ip_addressess=(
  "140.82.112.0/20"
  "143.55.64.0/20"
  "185.199.108.0/22"
  "192.30.252.0/22"
  "20.175.192.146/32"
  "20.175.192.147/32"
  "20.175.192.149/32"
  "20.175.192.150/32"
  "20.199.39.227/32"
  "20.199.39.228/32"
  "20.199.39.231/32"
  "20.199.39.232/32"
  "20.200.245.241/32"
  "20.200.245.245/32"
  "20.200.245.246/32"
  "20.200.245.247/32"
  "20.200.245.248/32"
  "20.201.28.144/32"
  "20.201.28.148/32"
  "20.201.28.149/32"
  "20.201.28.151/32"
  "20.201.28.152/32"
  "20.205.243.160/32"
  "20.205.243.164/32"
  "20.205.243.165/32"
  "20.205.243.166/32"
  "20.205.243.168/32"
  "20.207.73.82/32"
  "20.207.73.83/32"
  "20.207.73.85/32"
  "20.207.73.86/32"
  "20.207.73.88/32"
  "20.233.83.145/32"
  "20.233.83.146/32"
  "20.233.83.147/32"
  "20.233.83.149/32"
  "20.233.83.150/32"
  "20.248.137.48/32"
  "20.248.137.49/32"
  "20.248.137.50/32"
  "20.248.137.52/32"
  "20.248.137.55/32"
  "20.26.156.216/32"
  "20.27.177.113/32"
  "20.27.177.114/32"
  "20.27.177.116/32"
  "20.27.177.117/32"
  "20.27.177.118/32"
  "20.29.134.17/32"
  "20.29.134.18/32"
  "20.29.134.19/32"
  "20.29.134.23/32"
  "20.29.134.24/32"
  "20.87.245.0/32"
  "20.87.245.1/32"
  "20.87.245.4/32"
  "20.87.245.6/32"
  "20.87.245.7/32"
  "4.208.26.196/32"
  "4.208.26.197/32"
  "4.208.26.198/32"
  "4.208.26.199/32"
  "4.208.26.200/32"
)

for ip in "${github_runner_allow_out_bound_github_actions_ip_addressess[@]}"
do
  az storage account network-rule add --account-name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --ip-address $ip
done

for ip in "${github_runner_allow_out_bound_github_ip_addressess[@]}"
do
  az storage account network-rule add --account-name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --ip-address $ip
done

az storage account update --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --https-only true \
    --default-action Deny --bypass AzureServices Logging Metrics \
    --allow-blob-public-access false --allow-shared-key-access true

gh secret set AZURE_TF_RESOURCE_GROUP -b"$RESOURCE_GROUP" --repo $GITHUB_REPO
gh secret set AZURE_TF_STORAGE_ACCOUNT_NAME -b"$STORAGE_ACCOUNT_NAME" --repo $GITHUB_REPO
gh secret set AZURE_TF_CONTAINER_NAME -b"$CONTAINER_NAME" --repo $GITHUB_REPO
gh secret set AZURE_TF_LOCATION -b"$LOCATION" --repo $GITHUB_REPO

# Print a message indicating that the storage account and blob container have been successfully created.
# This setup is commonly used for storing Terraform state files in a remote backend configuration.
echo "Azure Storage Account and container created for Terraform backend."