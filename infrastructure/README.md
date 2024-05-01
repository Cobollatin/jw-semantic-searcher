<!-- BEGIN_TF_DOCS -->

This is a generated README.md file. Please do not edit directly. Instead, edit the file that generated this one and commit your changes.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 3.101.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | n/a |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.101.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_container_registry.use2_main_acr](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/container_registry) | resource |
| [azurerm_network_security_group.use2_swa_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/network_security_group) | resource |
| [azurerm_network_watcher.use2_main_nwwatcher](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/network_watcher) | resource |
| [azurerm_resource_group.use2_main_rg](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/resource_group) | resource |
| [azurerm_static_web_app.use2_main_swa](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/static_web_app) | resource |
| [azurerm_subnet.use2_swb_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.use2_as_subnet_nsg_association](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_user_assigned_identity.use2_main_acr_identity](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/user_assigned_identity) | resource |
| [azurerm_virtual_network.use2_main_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/virtual_network) | resource |
| [azuread_service_principal.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | The name of the application | `string` | n/a | yes |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common tags for all resources | `map(string)` | n/a | yes |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | The name of the environment (e.g., development, staging, production) | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where resources will be created | `string` | n/a | yes |
| <a name="input_location_short"></a> [location\_short](#input\_location\_short) | The short name of the Azure region where resources will be created | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_use2_main_swa"></a> [use2\_main\_swa](#output\_use2\_main\_swa) | n/a |

<!-- END_TF_DOCS -->