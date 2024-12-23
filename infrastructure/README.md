<!-- BEGIN_TF_DOCS -->

This is a generated README.md file. Please do not edit directly. Instead, edit the file that generated this one and commit your changes.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 3.109.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 2.51.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.105.0 |
| <a name="provider_github"></a> [github](#provider\_github) | 6.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.use2_main_swa_ai](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/application_insights) | resource |
| [azurerm_batch_account.use2_main_batch](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/batch_account) | resource |
| [azurerm_batch_job.use2_main_batch_job](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/batch_job) | resource |
| [azurerm_batch_pool.use2_main_batch_pool](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/batch_pool) | resource |
| [azurerm_container_registry.use2_main_acr](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/container_registry) | resource |
| [azurerm_container_registry_task.use2_main_acr_indexer_purge_task](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/container_registry_task) | resource |
| [azurerm_key_vault.use2_main_kv](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/key_vault) | resource |
| [azurerm_key_vault_access_policy.use2_main_kv_access_policy](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_access_policy.use2_main_sa_kv_access_policy](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_key.use2_main_sa_kv_key](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/key_vault_key) | resource |
| [azurerm_log_analytics_linked_storage_account.use2_main_sa_law_lsa](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/log_analytics_linked_storage_account) | resource |
| [azurerm_log_analytics_storage_insights.use2_sa_main_law_si](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/log_analytics_storage_insights) | resource |
| [azurerm_log_analytics_workspace.use2_main_law](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/log_analytics_workspace) | resource |
| [azurerm_log_analytics_workspace_table.use2_main_law_app_console_logs_table](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/log_analytics_workspace_table) | resource |
| [azurerm_log_analytics_workspace_table.use2_main_law_container_logs_table](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/log_analytics_workspace_table) | resource |
| [azurerm_log_analytics_workspace_table.use2_main_law_storage_logs_table](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/log_analytics_workspace_table) | resource |
| [azurerm_monitor_data_collection_endpoint.use2_main_sa_monitor](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/monitor_data_collection_endpoint) | resource |
| [azurerm_monitor_data_collection_rule_association.use2_main_sa_monitor_association](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/monitor_data_collection_rule_association) | resource |
| [azurerm_network_security_group.use2_bp_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.use2_kv_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.use2_sa_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/network_security_group) | resource |
| [azurerm_network_watcher.use2_main_nwwatcher](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/network_watcher) | resource |
| [azurerm_resource_group.use2_main_rg](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.use2_main_batch_acr_role](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.use2_main_batch_sa_role](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.use2_main_kv_role](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/role_assignment) | resource |
| [azurerm_search_service.use2_main_ss](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/search_service) | resource |
| [azurerm_static_web_app.use2_main_swa](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/static_web_app) | resource |
| [azurerm_storage_account.use2_main_sa](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/storage_account) | resource |
| [azurerm_storage_account_customer_managed_key.use2_main_sa_cmek](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/storage_account_customer_managed_key) | resource |
| [azurerm_storage_container.use2_main_batch_container](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/storage_container) | resource |
| [azurerm_subnet.use2_bp_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/subnet) | resource |
| [azurerm_subnet.use2_kv_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/subnet) | resource |
| [azurerm_subnet.use2_sa_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.use2_bp_subnet_nsg_association](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.use2_kv_subnet_nsg_association](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.use2_sa_subnet_nsg_association](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_user_assigned_identity.use2_main_acr_identity](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.use2_main_acr_indexer_purge_identity](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.use2_main_batch_identity](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.use2_main_law_identity](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.use2_main_sa_identity](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.use2_main_sb_identity](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/user_assigned_identity) | resource |
| [azurerm_virtual_network.use2_main_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/3.109.0/docs/resources/virtual_network) | resource |
| [github_actions_secret.use2_main_acr_login_server](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.use2_main_acr_name](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.use2_main_acr_rg](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.use2_main_batch_account_endpoint](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.use2_main_batch_account_key](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.use2_main_batch_account_name](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.use2_main_batch_job_id](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.use2_main_batch_pool_identity_id](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.use2_main_github_token](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.use2_main_indexer_config_name](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.use2_main_indexer_name](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.use2_main_openai_deployment_name](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.use2_main_openai_key](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.use2_main_openai_org_id](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.use2_main_openai_org_name](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.use2_main_openai_project_id](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.use2_main_openai_project_name](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.use2_main_sa_account_container_url](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.use2_main_semantic_seach_flag](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.use2_main_ss_api_key](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.use2_main_ss_name](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.use2_main_swa_api_key](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [azuread_service_principal.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |
| [github_actions_public_key.use2_main_acr_github_key](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/actions_public_key) | data source |
| [github_actions_public_key.use2_main_batch_github_key](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/actions_public_key) | data source |
| [github_actions_public_key.use2_main_swa_github_key](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/actions_public_key) | data source |
| [github_repository.use2_acr_github_repos](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/repository) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acr_repositories"></a> [acr\_repositories](#input\_acr\_repositories) | The list of repositories with Docker images | `list(string)` | n/a | yes |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | The name of the application | `string` | n/a | yes |
| <a name="input_batch_docker_images"></a> [batch\_docker\_images](#input\_batch\_docker\_images) | The list of Docker images for the batch job | `list(string)` | n/a | yes |
| <a name="input_batch_repositories"></a> [batch\_repositories](#input\_batch\_repositories) | The list of repositories with Docker images | `list(string)` | n/a | yes |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common tags for all resources | `map(string)` | n/a | yes |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | The name of the environment (e.g., development, staging, production) | `string` | n/a | yes |
| <a name="input_github_token"></a> [github\_token](#input\_github\_token) | The GitHub token for the GitHub Actions | `string` | n/a | yes |
| <a name="input_indexer_name"></a> [indexer\_name](#input\_indexer\_name) | The name of the Azure Search indexer | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where resources will be created | `string` | n/a | yes |
| <a name="input_location_short"></a> [location\_short](#input\_location\_short) | The short name of the Azure region where resources will be created | `string` | n/a | yes |
| <a name="input_openai_key"></a> [openai\_key](#input\_openai\_key) | The OpenAI API key | `string` | n/a | yes |
| <a name="input_openai_model"></a> [openai\_model](#input\_openai\_model) | The OpenAI model used for semantic search | `string` | n/a | yes |
| <a name="input_openai_org_id"></a> [openai\_org\_id](#input\_openai\_org\_id) | The OpenAI API organization ID | `string` | n/a | yes |
| <a name="input_openai_org_name"></a> [openai\_org\_name](#input\_openai\_org\_name) | The OpenAI API organization name | `string` | n/a | yes |
| <a name="input_openai_project_id"></a> [openai\_project\_id](#input\_openai\_project\_id) | The OpenAI API project ID | `string` | n/a | yes |
| <a name="input_openai_project_name"></a> [openai\_project\_name](#input\_openai\_project\_name) | The OpenAI API project name | `string` | n/a | yes |
| <a name="input_semantic_search_config_name"></a> [semantic\_search\_config\_name](#input\_semantic\_search\_config\_name) | The name of the Azure Search semantic search configuration | `string` | n/a | yes |
| <a name="input_sp_client_id"></a> [sp\_client\_id](#input\_sp\_client\_id) | The service principal client ID | `string` | n/a | yes |
| <a name="input_sp_tenant_id"></a> [sp\_tenant\_id](#input\_sp\_tenant\_id) | The service principal tenant ID | `string` | n/a | yes |
| <a name="input_swa_repository"></a> [swa\_repository](#input\_swa\_repository) | The GitHub repository for the Static Web App | `string` | n/a | yes |

## Outputs

No outputs.

<!-- END_TF_DOCS -->