#!/bin/bash

# Define variables with the subscription ID, application name, and GitHub repository information.
# These are used for logging in to Azure, creating a service principal, and storing Azure credentials as a GitHub secret.
SUBSCRIPTION_ID="b9d5d1cf-2f79-4a8f-a3d6-73ddca47caed"
APP_NAME="jw-semantic-searcher"
GITHUB_REPO="Cobollatin/jw-semantic-searcher" # The format is: user/repo

# Log in to Azure using the Azure CLI. This command requires that you have Azure CLI installed and that you are already authenticated.
az login

# Set the Azure account to use the specified subscription ID for subsequent operations.
az account set --subscription=$SUBSCRIPTION_ID

# Define the role to assign to the service principal. In this case, it's set to 'Owner'.
ROLE="Owner"

# Create a service principal for the application with the specified name and role.
# The '--scopes' parameter specifies the scope at which the service principal has access.
# Here, it's given access at the subscription level.
SERVICE_PRINCIPAL=$(az ad sp create-for-rbac --display-name="$APP_NAME" --role="$ROLE" --scopes="/subscriptions/$SUBSCRIPTION_ID")

# Extract important details from the service principal creation output.
# These details include the application (client) ID, the client secret (password), and the tenant ID.
SP_CLIENT_ID=$(echo $SERVICE_PRINCIPAL | jq -r '.appId')
SP_CLIENT_SECRET=$(echo $SERVICE_PRINCIPAL | jq -r '.password')
SP_TENANT_ID=$(echo $SERVICE_PRINCIPAL | jq -r '.tenant')

# The CLIENT_SECRET variable seems to be intended for use but is not correctly initialized from the service principal output.
# Instead, the SP_CLIENT_SECRET is already extracted and can be used directly.
# This line appears to be unnecessary and could be a mistake: CLIENT_SECRET=$(echo $SECRET | jq -r '.password')

# Prepare a JSON object containing the Azure credentials using `jq`.
# This JSON object includes the subscription ID, tenant ID, client ID, and client secret.
# It is prepared for setting as a GitHub secret in the specified repository.
AZURE_CREDENTIALS_JSON=$(jq -n \
                  --arg sub "$SUBSCRIPTION_ID" \
                  --arg ten "$SP_TENANT_ID" \
                  --arg cid "$SP_CLIENT_ID" \
                  --arg sec "$SP_CLIENT_SECRET" \
                  '{subscriptionId: $sub, tenantId: $ten, clientId: $cid, clientSecret: $sec}')

# Set the Azure credentials as a GitHub secret in the specified repository using the GitHub CLI.
gh secret set AZURE_CREDENTIALS -b"$AZURE_CREDENTIALS_JSON" --repo $GITHUB_REPO

# Assign the specified role to the service principal at the subscription scope.
# This solidifies the permissions the service principal has within the Azure subscription.
az role assignment create --assignee $SP_CLIENT_ID --role "$ROLE" --scope /subscriptions/$SUBSCRIPTION_ID

# Print a completion message indicating the Azure credentials have been created and stored,
# and the specified role has been assigned to the service principal.
echo "Azure credentials created and stored as secret. Role $ROLE assigned to the service principal."