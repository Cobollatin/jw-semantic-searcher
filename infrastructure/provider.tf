# This Terraform configuration snippet is used to configure the Microsoft Azure Provider. The Azure provider is used to interact with the many resources supported by Azure through Terraform.

provider "azurerm" {
  # The 'features' block is required for the Azure provider, but no features need to be specified at this time.
  # This block is used to enable or disable certain features of the Azure provider if needed.
  # Leaving it empty, as shown here, means that the default configuration is used and no specific features are enabled or disabled.
  # Service principal credentials are the pipeline's responsibility.
  features {}
}

provider "slack-app" {
}