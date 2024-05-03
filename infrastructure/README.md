<!-- BEGIN_TF_DOCS -->

This is a generated README.md file. Please do not edit directly. Instead, edit the file that generated this one and commit your changes.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 3.101.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | n/a |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.101.0 |
| <a name="provider_github"></a> [github](#provider\_github) | ~> 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_batch_account.use2_main_batch](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/batch_account) | resource |
| [azurerm_batch_job.use2_main_batch_job](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/batch_job) | resource |
| [azurerm_batch_pool.use2_main_batch_pool](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/batch_pool) | resource |
| [azurerm_container_registry.use2_main_acr](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/container_registry) | resource |
| [azurerm_network_security_group.use2_swa_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/network_security_group) | resource |
| [azurerm_network_watcher.use2_main_nwwatcher](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/network_watcher) | resource |
| [azurerm_resource_group.use2_main_rg](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.use2_main_batch_acr_role](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/role_assignment) | resource |
| [azurerm_static_web_app.use2_main_swa](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/static_web_app) | resource |
| [azurerm_storage_account.use2_main_sa](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/storage_account) | resource |
| [azurerm_subnet.use2_swb_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.use2_as_subnet_nsg_association](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_user_assigned_identity.use2_main_acr_identity](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.use2_main_batch_identity](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.use2_main_swa_identity](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/user_assigned_identity) | resource |
| [azurerm_virtual_network.use2_main_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/virtual_network) | resource |
| [github_actions_secret.use2_main_acr_name](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.use2_main_acr_rg](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.use2_main_batch_account_endpoint](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.use2_main_batch_account_key](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.use2_main_batch_account_name](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.use2_main_batch_job_id](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.use2_main_swa_api_key](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [azuread_service_principal.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/data-sources/client_config) | data source |
| [github_actions_public_key.use2_main_acr_github_key](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/actions_public_key) | data source |
| [github_actions_public_key.use2_main_batch_github_key](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/actions_public_key) | data source |
| [github_actions_public_key.use2_main_swa_github_key](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/actions_public_key) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acr_repositories"></a> [acr\_repositories](#input\_acr\_repositories) | The list of repositories with Docker images | `list(string)` | n/a | yes |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | The name of the application | `string` | n/a | yes |
| <a name="input_batch_docker_images"></a> [batch\_docker\_images](#input\_batch\_docker\_images) | The list of Docker images for the batch job | `list(string)` | n/a | yes |
| <a name="input_batch_repositories"></a> [batch\_repositories](#input\_batch\_repositories) | The list of repositories with Docker images | `list(string)` | n/a | yes |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common tags for all resources | `map(string)` | n/a | yes |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | The name of the environment (e.g., development, staging, production) | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where resources will be created | `string` | n/a | yes |
| <a name="input_location_short"></a> [location\_short](#input\_location\_short) | The short name of the Azure region where resources will be created | `string` | n/a | yes |
| <a name="input_swa_repository"></a> [swa\_repository](#input\_swa\_repository) | The GitHub repository for the Static Web App | `string` | n/a | yes |

## Outputs

No outputs.

<!-- END_TF_DOCS -->