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
  #checkov:skip=CKV_AZURE_10:We need to allow ssh from the internet
  name                = "${var.app_name}-${var.location_short}-${var.environment_name}-as-nsg"
  location            = azurerm_resource_group.use2_main_rg.location
  resource_group_name = azurerm_resource_group.use2_main_rg.name
  tags                = var.common_tags
  security_rule {
    name                       = "BatchNodeManagementInbound"
    priority                   = 100
    protocol                   = "Tcp"
    direction                  = "Inbound"
    access                     = "Allow"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "29876-29877"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "BatchNodeManagementOutbound"
    priority                   = 100
    protocol                   = "*"
    direction                  = "Outbound"
    access                     = "Allow"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "443"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "SSHInbound"
    priority                   = 200
    protocol                   = "Tcp"
    direction                  = "Inbound"
    access                     = "Allow"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "22"
    destination_address_prefix = "*"
  }
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

resource "github_actions_secret" "use2_main_acr_login_server" {
  #checkov:skip=CKV_GIT_4:Not sending sensitive data to the repository, encriptions not needed
  for_each        = toset(var.acr_repositories)
  repository      = each.value
  secret_name     = "AZURE_CONTAINER_REGISTRY_SERVER"
  plaintext_value = azurerm_container_registry.use2_main_acr.login_server
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

resource "azurerm_user_assigned_identity" "use2_main_acr_indexer_purge_identity" {
  name                = "${var.app_name}-${var.location_short}-${var.environment_name}-acr-purge-identity"
  location            = azurerm_resource_group.use2_main_rg.location
  resource_group_name = azurerm_resource_group.use2_main_rg.name
  tags                = var.common_tags
}

resource "azurerm_container_registry_task" "use2_main_acr_indexer_purge_task" {
  name                  = "${var.app_name}-${var.location_short}-${var.environment_name}-acr-purge-task"
  container_registry_id = azurerm_container_registry.use2_main_acr.id
  agent_pool_name       = "Default"
  is_system_task        = false
  enabled               = true
  tags                  = var.common_tags
  encoded_step {
    task_content = <<EOF
version: v1.1.0
steps: 
  - cmd: acr purge acr purge --filter 'indexer:.*' --untagged --keep 10
    disableWorkingDirectoryOverride: true
    timeout: 3600
EOF
  }
  platform {
    os = "Linux"
  }
  timer_trigger {
    name     = "PurgeTimer"
    schedule = "0 0 * * *"
    enabled  = true
  }
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.use2_main_acr_indexer_purge_identity.id,
    ]
  }
}

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
# Storage Account

resource "azurerm_storage_account" "use2_main_sa" {
  #checkov:skip=CKV_AZURE_59:We need to allow public access to the storage account
  #checkov:skip=CKV_AZURE_190:We need to allow public access to the blobs
  #checkov:skip=CKV_AZURE_206:No replication in free tier
  #checkov:skip=CKV_AZURE_33:We dont need logging for this storage account
  #checkov:skip=CKV2_AZURE_41:We dont need sas policy for this storage account
  #checkov:skip=CKV2_AZURE_33:We dont need private endpoint for this storage account
  #checkov:skip=CKV2_AZURE_38:We dont need soft delete for this storage account
  #checkov:skip=CKV2_AZURE_47:We want anonymous access to the blobs
  #checkov:skip=CKV2_AZURE_40:We want to use shared key authentication
  #checkov:skip=CKV2_AZURE_1:We dont need encryption at rest for this storage account
  #checkov:skip=CKV_AZURE_43:False positive, the name follows the naming convention
  name                     = lower("${substr(var.app_name, 0, 4)}${var.location_short}${var.environment_name}sa")
  location                 = azurerm_resource_group.use2_main_rg.location
  resource_group_name      = azurerm_resource_group.use2_main_rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
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
  name                                = lower("${substr(var.app_name, 0, 8)}${var.location_short}${var.environment_name}batch")
  location                            = azurerm_resource_group.use2_main_rg.location
  resource_group_name                 = azurerm_resource_group.use2_main_rg.name
  pool_allocation_mode                = "BatchService"
  public_network_access_enabled       = true
  storage_account_id                  = azurerm_storage_account.use2_main_sa.id
  storage_account_authentication_mode = "StorageKeys"
  tags                                = var.common_tags
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.use2_main_batch_identity.id,
    ]
  }
}

resource "azurerm_role_assignment" "use2_main_batch_acr_role" {
  scope                = azurerm_container_registry.use2_main_acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.use2_main_batch_identity.principal_id
  description          = "Allow the Batch Pool VM to pull images from the ACR"
}

resource "azurerm_batch_pool" "use2_main_batch_pool" {
  name                = "${var.app_name}-${var.location_short}-${var.environment_name}-batch-pool"
  resource_group_name = azurerm_resource_group.use2_main_rg.name
  account_name        = azurerm_batch_account.use2_main_batch.name
  node_agent_sku_id   = "batch.node.ubuntu 20.04"
  vm_size             = "Standard_A1_v2"
  max_tasks_per_node  = 1
  storage_image_reference {
    publisher = "microsoft-azure-batch"
    offer     = "ubuntu-server-container"
    sku       = "20-04-lts"
    version   = "latest"
  }
  auto_scale {
    evaluation_interval = "PT5M"
    formula             = <<EOF
$sample = $PendingTasks.GetSample(TimeInterval_Minute * 15);
$tasks = max($sample);
$targetVMs = $tasks > 0 ? $tasks : max(0, $TargetDedicatedNodes / 2);
minPoolSize = 0;
cappedPoolSize = 1;
$TargetDedicatedNodes = max(minPoolSize, min($targetVMs, cappedPoolSize));
$NodeDeallocationOption = taskcompletion;
EOF
  }
  network_configuration {
    subnet_id = azurerm_subnet.use2_swb_subnet.id
  }
  container_configuration {
    type = "DockerCompatible"
    container_registries {
      registry_server           = azurerm_container_registry.use2_main_acr.login_server
      user_assigned_identity_id = azurerm_user_assigned_identity.use2_main_batch_identity.id
    }
    container_image_names = [for name in var.batch_docker_images : "${azurerm_container_registry.use2_main_acr.login_server}/${name}:latest"]
  }
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.use2_main_batch_identity.id,
    ]
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
  plaintext_value = azurerm_batch_job.use2_main_batch_job.name
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
