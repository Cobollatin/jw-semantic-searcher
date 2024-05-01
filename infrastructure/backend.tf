# This Terraform configuration snippet specifies the backend for storing Terraform state files. 
# Terraform backends determine how state is loaded and how an operation such as apply is executed. 
# This configuration is for using Azure Blob Storage as the backend for Terraform state storage.

terraform {
  # The 'backend' block configures the storage backend for Terraform state. 
  # In this case, "azurerm" is specified to use Azure Resource Manager for state storage.
  backend "azurerm" {
    # The 'key' is the name of the state file when stored in the backend. 
    # In this example, the state file will be named "dev.eus2.terraform.tfstate".
    # This is important for distinguishing between different state files, especially when managing multiple environments.
    key = "dev.eus2.terraform.tfstate"

    # Note: Additional mandatory configurations for the AzureRM backend are not specified here.
    # The 'storage_account_name', 'container_name', and 'access_key' are the pipeline's responsibility.
  }
}