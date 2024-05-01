#!/bin/bash

# This bash script is designed to bootstrap an Azure environment by first creating
# Azure credentials and then creating a storage account. It is intended to be run
# in environments where these Azure resources need to be set up automatically.

# Stop execution if any command fails. This ensures that the script doesn't continue
# if there is an error, helping prevent potential issues or inconsistencies.
set -e

# Define the paths to the scripts that will create Azure credentials and a storage account.
# It is assumed these scripts are located in the same directory as the current script.
CREATE_AZURE_CREDENTIALS_SCRIPT="./create_azure_credentials.sh"
CREATE_AZURE_STORAGE_ACCOUNT_SCRIPT="./create_azure_storage_account.sh"

# Make sure both scripts that are necessary for setting up the environment
# are executable. This is a precaution to avoid run-time errors related to permissions.
chmod +x $CREATE_AZURE_CREDENTIALS_SCRIPT $CREATE_AZURE_STORAGE_ACCOUNT_SCRIPT

# Inform the user that Azure credentials creation is starting.
echo "Creating Azure Credentials..."
# Execute the script to create Azure credentials.
$CREATE_AZURE_CREDENTIALS_SCRIPT

# Inform the user that the creation of the Azure Storage Account is starting.
echo "Creating Azure Storage Account..."
# Execute the script to create the Azure Storage Account.
$CREATE_AZURE_STORAGE_ACCOUNT_SCRIPT

# Indicate to the user that the bootstrap process is complete.
echo "Bootstrap complete!"