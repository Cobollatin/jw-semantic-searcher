#!/bin/bash

# Initialize Terraform and apply the configuration
cd infrastructure
terraform init
terraform apply -auto-approve

# Retrieve the outputs from Terraform
SEARCH_SERVICE_NAME=$(terraform output -raw search_service_name)
SEARCH_INDEX_NAME=$(terraform output -raw search_index_name)
SEARCH_SERVICE_ADMIN_KEY=$(terraform output -raw search_service_admin_key)

# Export the environment variables
export AZURE_SEARCH_SERVICE_NAME=$SEARCH_SERVICE_NAME
export AZURE_SEARCH_INDEX_NAME=$SEARCH_INDEX_NAME
export AZURE_SEARCH_API_KEY=$SEARCH_SERVICE_ADMIN_KEY

# Build the Docker image
docker build -t indexer-image .

# Run the Docker container
docker run -e AZURE_SEARCH_SERVICE_NAME="$AZURE_SEARCH_SERVICE_NAME" \
           -e AZURE_SEARCH_INDEX_NAME="$AZURE_SEARCH_INDEX_NAME" \
           -e AZURE_SEARCH_API_KEY="$AZURE_SEARCH_API_KEY" \
           --rm indexer-image
