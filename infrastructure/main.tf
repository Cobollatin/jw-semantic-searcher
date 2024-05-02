############################################################################################################################
# General
resource "azurerm_resource_group" "use2_main_rg" {
  name     = "${var.app_name}-${var.location_short}-${var.environment_name}-rg"
  location = var.location
  tags     = var.common_tags
}

data "azurerm_client_config" "current" {}

data "azuread_service_principal" "current" {
  client_id = data.azurerm_client_config.current.client_id
}

############################################################################################################################
# Networking
resource "azurerm_virtual_network" "use2_main_vnet" {
  name                = "${var.app_name}-${var.location_short}-${var.environment_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.use2_main_rg.location
  resource_group_name = azurerm_resource_group.use2_main_rg.name
  tags                = var.common_tags
}

resource "azurerm_subnet" "use2_swb_subnet" {
  name                                      = "${var.app_name}-${var.location_short}-${var.environment_name}-as-subnet"
  resource_group_name                       = azurerm_resource_group.use2_main_rg.name
  virtual_network_name                      = azurerm_virtual_network.use2_main_vnet.name
  address_prefixes                          = ["10.0.0.0/24"]
  private_endpoint_network_policies_enabled = false
  service_endpoints                         = ["Microsoft.Web", ]
}

resource "azurerm_network_security_group" "use2_swa_nsg" {
  name                = "${var.app_name}-${var.location_short}-${var.environment_name}-as-nsg"
  location            = azurerm_resource_group.use2_main_rg.location
  resource_group_name = azurerm_resource_group.use2_main_rg.name
  tags                = var.common_tags
}

resource "azurerm_subnet_network_security_group_association" "use2_as_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.use2_swb_subnet.id
  network_security_group_id = azurerm_network_security_group.use2_swa_nsg.id
}

############################################################################################################################
# Network Watcher
resource "azurerm_network_watcher" "use2_main_nwwatcher" {
  name                = "${var.app_name}-${var.location_short}-${var.environment_name}-nw-watcher"
  location            = azurerm_resource_group.use2_main_rg.location
  resource_group_name = azurerm_resource_group.use2_main_rg.name
  tags                = var.common_tags
}

############################################################################################################################
# ACR

resource "azurerm_user_assigned_identity" "use2_main_acr_identity" {
  name                = "${var.app_name}-${var.location_short}-${var.environment_name}-acr-identity"
  location            = azurerm_resource_group.use2_main_rg.location
  resource_group_name = azurerm_resource_group.use2_main_rg.name
  tags                = var.common_tags
}


resource "azurerm_container_registry" "use2_main_acr" {
  #checkov:skip=CKV_AZURE_233:We need premium tier for zone-redundancy
  #checkov:skip=CKV_AZURE_167:We need premium tier for retention policy
  #checkov:skip=CKV_AZURE_166:We need premium tier for quarantine policy
  #checkov:skip=CKV_AZURE_165:We need premium tier for geo-replication
  #checkov:skip=CKV_AZURE_164:We need premium tier for trust policy
  #checkov:skip=CKV_AZURE_163:We only can afford basic tier
  #checkov:skip=CKV_AZURE_237:We cant use dedicated data endpoints because we only have basic tier
  #checkov:skip=CKV_AZURE_139:We dont have a self-hosted runner in the pipeline yet, so we need to skip this check because the runner needs access
  name                       = "${var.app_name}${var.location_short}${var.environment_name}acr"
  location                   = azurerm_resource_group.use2_main_rg.location
  resource_group_name        = azurerm_resource_group.use2_main_rg.name
  sku                        = "Basic"
  admin_enabled              = false
  network_rule_bypass_option = "AzureServices"
  tags                       = var.common_tags

  # network_rule_set {
  #   default_action = "Allow"
  # }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.use2_main_acr_identity.id,
    ]
  }
}

data "github_actions_public_key" "use2_main_acr_github_key" {
  for_each   = toset(var.acr_repositories)
  repository = each.value
}

resource "github_actions_secret" "use2_main_acr_rg" {
  #checkov:skip=CKV_GIT_4:Not sending sensitive data to the repository, encriptions not needed
  for_each        = toset(var.acr_repositories)
  repository      = each.value
  secret_name     = "ACR_RESOURCE_GROUP"
  plaintext_value = azurerm_container_registry.use2_main_acr.resource_group_name
}

resource "github_actions_secret" "use2_main_acr_name" {
  #checkov:skip=CKV_GIT_4:Not sending sensitive data to the repository, encriptions not needed
  for_each        = toset(var.acr_repositories)
  repository      = each.value
  secret_name     = "AZURE_CONTAINER_REGISTRY"
  plaintext_value = azurerm_container_registry.use2_main_acr.name
}

# resource "azurerm_private_endpoint" "use2_main_acr_pe" {
#   name                          = "${var.app_name}-${var.location_short}-${var.environment_name}-acr-pe"
#   location                      = azurerm_resource_group.use2_main_rg.location
#   resource_group_name           = azurerm_resource_group.use2_main_rg.name
#   subnet_id                     = azurerm_subnet.use2_acr_subnet.id
#   custom_network_interface_name = "${var.app_name}-${var.location_short}-${var.environment_name}-acr-pe-nic"
#   tags                          = var.common_tags
#   private_service_connection {
#     name                           = "${var.app_name}-${var.location_short}-${var.environment_name}-acr-pe-connection"
#     is_manual_connection           = false
#     private_connection_resource_id = azurerm_container_registry.use2_main_acr.id
#     subresource_names              = ["registry"]
#   }
# }

############################################################################################################################
# SWA

resource "azurerm_user_assigned_identity" "use2_main_swa_identity" {
  name                = "${var.app_name}-${var.location_short}-${var.environment_name}-swa-identity"
  location            = azurerm_resource_group.use2_main_rg.location
  resource_group_name = azurerm_resource_group.use2_main_rg.name
  tags                = var.common_tags
}

resource "azurerm_static_web_app" "use2_main_swa" {
  name                               = "${var.app_name}-${var.location_short}-${var.environment_name}-swa"
  resource_group_name                = azurerm_resource_group.use2_main_rg.name
  location                           = azurerm_resource_group.use2_main_rg.location
  preview_environments_enabled       = false
  configuration_file_changes_enabled = false
  sku_tier                           = "Free"
  sku_size                           = "Free"
  tags                               = var.common_tags
  # We cant use the identity under the free tier
  # identity {
  #   type = "UserAssigned"
  #   identity_ids = [
  #     azurerm_user_assigned_identity.use2_main_swa_identity.id,
  #   ]
  # }
}

data "github_actions_public_key" "use2_main_swa_github_key" {
  repository = var.swa_repository
}

resource "github_actions_secret" "use2_main_swa_api_key" {
  #checkov:skip=CKV_GIT_4:Not sending sensitive data to the repository, encriptions not needed
  repository      = var.swa_repository
  secret_name     = "AZURE_STATIC_WEB_APPS_API_TOKEN"
  plaintext_value = azurerm_static_web_app.use2_main_swa.api_key
}

############################################################################################################################
# Batch

resource "azurerm_user_assigned_identity" "use2_main_batch_identity" {
  name                = "${var.app_name}-${var.location_short}-${var.environment_name}-batch-identity"
  location            = azurerm_resource_group.use2_main_rg.location
  resource_group_name = azurerm_resource_group.use2_main_rg.name
  tags                = var.common_tags
}

resource "azurerm_batch_account" "use2_main_batch" {
  #checkov:skip=CKV_AZURE_76:Managed encryption is enough for our needs
  name                          = lower("${substr(var.app_name, 0, 8)}${var.location_short}${var.environment_name}batch")
  location                      = azurerm_resource_group.use2_main_rg.location
  resource_group_name           = azurerm_resource_group.use2_main_rg.name
  pool_allocation_mode          = "UserSubscription"
  public_network_access_enabled = true
  tags                          = var.common_tags
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.use2_main_batch_identity.id,
    ]
  }
}

resource "azurerm_user_assigned_identity" "use2_main_batch_pool_acr_identity" {
  name                = "${var.app_name}-${var.location_short}-${var.environment_name}-batch-pool-acr-identity"
  location            = azurerm_resource_group.use2_main_rg.location
  resource_group_name = azurerm_resource_group.use2_main_rg.name
  tags                = var.common_tags
}

resource "azurerm_role_assignment" "use2_main_batch_acr_role" {
  scope                = azurerm_container_registry.use2_main_acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.use2_main_batch_pool_acr_identity.principal_id
  description          = "Allow the Batch Pool VM to pull images from the ACR"
}

resource "azurerm_batch_pool" "use2_main_batch_pool" {
  name                = "${var.app_name}-${var.location_short}-${var.environment_name}-batch-pool"
  resource_group_name = azurerm_resource_group.use2_main_rg.name
  account_name        = azurerm_batch_account.use2_main_batch.name
  node_agent_sku_id   = "batch.node.ubuntu 20.04"
  vm_size             = "Basic_A1"
  max_tasks_per_node  = 1
  storage_image_reference {
    publisher = "microsoft-azure-batch"
    offer     = "ubuntu-server-container"
    sku       = "20-04-lts"
    version   = "latest"
  }
  fixed_scale {
    target_dedicated_nodes    = 1
    target_low_priority_nodes = 0
  }
  container_configuration {
    type = "DockerCompatible"
    container_registries {
      registry_server           = azurerm_container_registry.use2_main_acr.login_server
      user_assigned_identity_id = azurerm_user_assigned_identity.use2_main_batch_pool_acr_identity.id
    }
    container_image_names = var.batch_docker_images
  }
}

resource "azurerm_batch_job" "use2_main_batch_job" {
  name          = "${var.app_name}-${var.location_short}-${var.environment_name}-batch-job"
  batch_pool_id = azurerm_batch_pool.use2_main_batch_pool.id
}

data "github_actions_public_key" "use2_main_batch_github_key" {
  for_each   = toset(var.batch_repositories)
  repository = each.value
}

resource "github_actions_secret" "use2_main_batch_job_id" {
  #checkov:skip=CKV_GIT_4:Not sending sensitive data to the repository, encriptions not needed
  for_each        = toset(var.batch_repositories)
  repository      = each.value
  secret_name     = "BATCH_JOB_ID"
  plaintext_value = azurerm_batch_job.use2_main_batch_job.id
}

resource "github_actions_secret" "use2_main_batch_account_endpoint" {
  #checkov:skip=CKV_GIT_4:Not sending sensitive data to the repository, encriptions not needed
  for_each        = toset(var.batch_repositories)
  repository      = each.value
  secret_name     = "BATCH_ACCOUNT_ENDPOINT"
  plaintext_value = azurerm_batch_account.use2_main_batch.account_endpoint
}

resource "github_actions_secret" "use2_main_batch_account_key" {
  #checkov:skip=CKV_GIT_4:Not sending sensitive data to the repository, encriptions not needed
  for_each        = toset(var.batch_repositories)
  repository      = each.value
  secret_name     = "BATCH_ACCOUNT_KEY"
  plaintext_value = azurerm_batch_account.use2_main_batch.primary_access_key
}

resource "github_actions_secret" "use2_main_batch_account_name" {
  #checkov:skip=CKV_GIT_4:Not sending sensitive data to the repository, encriptions not needed
  for_each        = toset(var.batch_repositories)
  repository      = each.value
  secret_name     = "BATCH_ACCOUNT_NAME"
  plaintext_value = azurerm_batch_account.use2_main_batch.name
}
