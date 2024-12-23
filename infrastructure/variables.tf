# This Terraform script defines several variables that are used to configure the infrastructure deployment. Variables in Terraform are a way to parameterize your configurations to make them more reusable and flexible.

# Variable for the application name
variable "app_name" {
  description = "The name of the application" # Provides a description of the variable, which is helpful for documentation and when prompting for input.
  type        = string                        # Specifies the data type of the variable, in this case, a string.
}

# Variable for the service principal client ID
variable "sp_client_id" {
  description = "The service principal client ID" # Provides a description of the variable, which is helpful for documentation and when prompting for input.
  type        = string                            # Specifies the data type of the variable, in this case, a string.
  sensitive   = true                              # Indicates whether the value of the variable should be treated as sensitive and not displayed in logs or outputs.
}

# Variable for the service principal tenant ID
variable "sp_tenant_id" {
  description = "The service principal tenant ID" # Provides a description of the variable, which is helpful for documentation and when prompting for input.
  type        = string                            # Specifies the data type of the variable, in this case, a string.
  sensitive   = true                              # Indicates whether the value of the variable should be treated as sensitive and not displayed in logs or outputs.
}

# Variable for the Azure region
variable "location" {
  description = "The Azure region where resources will be created" # The Azure region (e.g., "East US", "West Europe") where the resources for this project will be deployed.
  type        = string                                             # Indicates the variable value is expected to be a string.
}

# Variable for the short name of the Azure region
variable "location_short" {
  description = "The short name of the Azure region where resources will be created" # A shorter or abbreviated version of the Azure region name, potentially used for naming resources.
  type        = string                                                               # String data type indicates the value is textual.
}

# Variable for the environment name
variable "environment_name" {
  description = "The name of the environment (e.g., development, staging, production)" # Describes the deployment environment for which the infrastructure is being provisioned.
  type        = string                                                                 # The value of this variable is a string.
}

# Variable for common tags
variable "common_tags" {
  description = "Common tags for all resources" # Tags are key-value pairs associated with resources. Common tags might include metadata like project name, environment, or cost center.
  type        = map(string)                     # Specifies that this variable is a map of strings, allowing for key-value pairs where both keys and values are strings.
}

# Variable for a swa repository
variable "swa_repository" {
  description = "The GitHub repository for the Static Web App" # Specifies the GitHub repository where the Static Web App is hosted.
  type        = string                                         # The value of this variable is a string.
}

# Variable for the repositories with docker images
variable "acr_repositories" {
  description = "The list of repositories with Docker images" # Specifies a list of repositories that contain Docker images.
  type        = list(string)                                  # Indicates that this variable is a list of strings.
}

# Variable for the repositories with docker images
variable "indexer_name" {
  description = "The name of the Azure Search indexer" # Specifies the name of the Azure Search indexer.
  type        = string                                 # The value of this variable is a string.
}

# Variable for the repositories with docker images
variable "semantic_search_config_name" {
  description = "The name of the Azure Search semantic search configuration" # Specifies the name of the Azure Search semantic search configuration.
  type        = string                                                       # The value of this variable is a string.
}

# Variable for the repositories with docker images
variable "openai_key" {
  description = "The OpenAI API key" # Specifies the OpenAI API key used for the semantic search configuration.
  type        = string               # The value of this variable is a string.
  sensitive   = true                 # Indicates that the value of this variable should be treated as sensitive and not displayed in logs or outputs.
}

# Variable for the repositories with docker images
variable "openai_project_name" {
  description = "The OpenAI API project name" # Specifies the OpenAI API project name used for the semantic search configuration.
  type        = string                        # The value of this variable is a string.
}

# Variable for the repositories with docker images
variable "openai_project_id" {
  description = "The OpenAI API project ID" # Specifies the OpenAI API project ID used for the semantic search configuration.
  type        = string                      # The value of this variable is a string.
}

# Variable for the repositories with docker images
variable "openai_org_name" {
  description = "The OpenAI API organization name" # Specifies the OpenAI API organization name used for the semantic search configuration.
  type        = string                             # The value of this variable is a string.
}

# Variable for the repositories with docker images
variable "openai_org_id" {
  description = "The OpenAI API organization ID" # Specifies the OpenAI API organization ID used for the semantic search configuration.
  type        = string                           # The value of this variable is a string.
}

# Variable for the repositories with docker images
variable "openai_model" {
  description = "The OpenAI model used for semantic search" # Specifies the OpenAI model used for the semantic search configuration.
  type        = string                                      # The value of this variable is a string.
}

# Variable for the repositories with batch jobs
variable "batch_repositories" {
  description = "The list of repositories with Docker images" # Specifies a list of repositories that contain a batch job.
  type        = list(string)                                  # Indicates that this variable is a list of strings.
}

# Variable for the batch docker images
variable "batch_docker_images" {
  description = "The list of Docker images for the batch job" # Specifies a list of Docker images that are used for the batch job.
  type        = list(string)                                  # Indicates that this variable is a list of strings.
}

variable "github_token" {
  description = "The GitHub token for the GitHub Actions" # Specifies the GitHub token used for GitHub Actions.
  type        = string                                    # The value of this variable is a string.
  sensitive   = true                                      # Indicates that the value of this variable should be treated as sensitive and not displayed in logs or outputs.
}
