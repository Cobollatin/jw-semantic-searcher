# This Terraform configuration snippet specifies the provider requirements for a Terraform project.

terraform {
  # 'required_providers' block defines the providers required by this Terraform configuration.
  required_providers {
    # Here, 'azurerm' is specified as a required provider.
    azurerm = {
      source  = "hashicorp/azurerm" # The 'source' attribute specifies the location from which Terraform should download the provider. In this case, it's from HashiCorp's official provider registry.
      version = "3.105.0"           # The 'version' attribute locks the provider to version 3.94.0. This ensures consistency and predictability in deployments, as Terraform will use this specific version of the provider.
    }

    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}
