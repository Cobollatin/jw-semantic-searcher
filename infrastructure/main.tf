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
  is_system_task        = false
  enabled               = true
  tags                  = var.common_tags
  encoded_step {
    task_content = <<EOF
version: v1.1.0
steps: 
  - cmd: acr purge acr purge --filter 'indexer:.*' --keep 10 --untagged
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
# Logging

resource "azurerm_log_analytics_workspace" "use2_main_law" {
  name                = "${var.app_name}-${var.location_short}-${var.environment_name}-law"
  location            = azurerm_resource_group.use2_main_rg.location
  resource_group_name = azurerm_resource_group.use2_main_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  daily_quota_gb      = 0.2
  tags                = var.common_tags
}

############################################################################################################################
# SWA

# resource "azurerm_user_assigned_identity" "use2_main_swa_identity" {
#   name                = "${var.app_name}-${var.location_short}-${var.environment_name}-swa-identity"
#   location            = azurerm_resource_group.use2_main_rg.location
#   resource_group_name = azurerm_resource_group.use2_main_rg.name
#   tags                = var.common_tags
# }

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
# Key Vault

resource "azurerm_subnet" "use2_kv_subnet" {
  name                                      = "${var.app_name}-${var.location_short}-${var.environment_name}-kv-subnet"
  resource_group_name                       = azurerm_resource_group.use2_main_rg.name
  virtual_network_name                      = azurerm_virtual_network.use2_main_vnet.name
  address_prefixes                          = ["10.0.10.0/24"]
  private_endpoint_network_policies_enabled = false
  service_endpoints                         = ["Microsoft.KeyVault", ]
}

resource "azurerm_network_security_group" "use2_kv_nsg" {
  name                = "${var.app_name}-${var.location_short}-${var.environment_name}-kv-nsg"
  location            = azurerm_resource_group.use2_main_rg.location
  resource_group_name = azurerm_resource_group.use2_main_rg.name
  tags                = var.common_tags
}

resource "azurerm_subnet_network_security_group_association" "use2_kv_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.use2_kv_subnet.id
  network_security_group_id = azurerm_network_security_group.use2_kv_nsg.id
}

resource "azurerm_key_vault" "use2_main_kv" {
  #checkov:skip=CKV_AZURE_189:We dont have a self-hosted runner in the pipeline yet, so we need to skip this check because the runner needs access
  #checkov:skip=CKV_AZURE_109:We dont have a self-hosted runner in the pipeline yet, so we need to skip this check because the runner needs access
  name                          = lower("${substr(var.app_name, 0, 4)}${var.location_short}${var.environment_name}kv")
  location                      = azurerm_resource_group.use2_main_rg.location
  resource_group_name           = azurerm_resource_group.use2_main_rg.name
  enabled_for_disk_encryption   = true
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days    = 7
  purge_protection_enabled      = true
  public_network_access_enabled = true // This will be false when we have a self-hosted runner
  sku_name                      = "standard"
  tags                          = var.common_tags

  network_acls {
    bypass                     = "AzureServices"
    default_action             = "Allow"
    virtual_network_subnet_ids = [azurerm_subnet.use2_kv_subnet.id]
  }
}

resource "azurerm_role_assignment" "use2_main_kv_role" {
  scope                = azurerm_resource_group.use2_main_rg.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azuread_service_principal.current.object_id
  description          = "Allow the Service Principal to manage the Key Vault"
}

resource "azurerm_key_vault_access_policy" "use2_main_kv_access_policy" {
  key_vault_id = azurerm_key_vault.use2_main_kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_service_principal.current.object_id
  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "Purge",
    "Recover",
    "Update",
    "GetRotationPolicy",
    "SetRotationPolicy"
  ]

  secret_permissions = [
    "Get",
    "Delete",
  ]

  storage_permissions = [
    "Get",
    "Delete",
  ]
}

resource "azurerm_private_endpoint" "use2_main_kv_pe" {
  name                          = "${var.app_name}-${var.location_short}-${var.environment_name}-kv-pe"
  location                      = azurerm_resource_group.use2_main_rg.location
  resource_group_name           = azurerm_resource_group.use2_main_rg.name
  subnet_id                     = azurerm_subnet.use2_kv_subnet.id
  custom_network_interface_name = "${var.app_name}-${var.location_short}-${var.environment_name}-kv-pe-nic"
  tags                          = var.common_tags

  private_service_connection {
    name                           = "${var.app_name}-${var.location_short}-${var.environment_name}-kv-pe-connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.use2_main_kv.id
    subresource_names              = ["vault"]
  }
}

resource "azurerm_user_assigned_identity" "use2_main_sb_identity" {
  name                = "${var.app_name}-${var.location_short}-${var.environment_name}-sb-identity"
  location            = azurerm_resource_group.use2_main_rg.location
  resource_group_name = azurerm_resource_group.use2_main_rg.name
  tags                = var.common_tags
}

############################################################################################################################
# Storage Account

resource "azurerm_subnet" "use2_sa_subnet" {
  name                                      = "${var.app_name}-${var.location_short}-${var.environment_name}-sa-subnet"
  resource_group_name                       = azurerm_resource_group.use2_main_rg.name
  virtual_network_name                      = azurerm_virtual_network.use2_main_vnet.name
  address_prefixes                          = ["10.0.20.0/24"]
  private_endpoint_network_policies_enabled = false
  service_endpoints                         = ["Microsoft.Storage", ]
}

resource "azurerm_network_security_group" "use2_sa_nsg" {
  name                = "${var.app_name}-${var.location_short}-${var.environment_name}-sa-nsg"
  location            = azurerm_resource_group.use2_main_rg.location
  resource_group_name = azurerm_resource_group.use2_main_rg.name
  tags                = var.common_tags
}

resource "azurerm_subnet_network_security_group_association" "use2_sa_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.use2_sa_subnet.id
  network_security_group_id = azurerm_network_security_group.use2_sa_nsg.id
}

resource "azurerm_key_vault_key" "use2_main_sa_kv_key" {
  #checkov:skip=CKV_AZURE_112:We need premium tier for HSM keys
  name            = "${var.app_name}-${var.location_short}-${var.environment_name}-sa-key"
  key_vault_id    = azurerm_key_vault.use2_main_kv.id
  key_type        = "RSA"
  key_size        = 2048
  expiration_date = "2024-12-30T20:00:00Z"
  tags            = var.common_tags

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }

    expire_after         = "P90D"
    notify_before_expiry = "P29D"
  }
}

resource "azurerm_user_assigned_identity" "use2_main_sa_identity" {
  name                = "${var.app_name}-${var.location_short}-${var.environment_name}-sa-identity"
  location            = azurerm_resource_group.use2_main_rg.location
  resource_group_name = azurerm_resource_group.use2_main_rg.name
  tags                = var.common_tags
}

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
  #checkov:skip=CKV_AZURE_35:We dont have a self-hosted runner in the pipeline yet, so we need to skip this check because the runner needs access
  name                     = lower("${substr(var.app_name, 0, 4)}${var.location_short}${var.environment_name}sa")
  location                 = azurerm_resource_group.use2_main_rg.location
  resource_group_name      = azurerm_resource_group.use2_main_rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  queue_properties {
    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 10
    }
  }

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  network_rules {
    default_action             = "Allow"
    bypass                     = ["AzureServices", "Logging", "Metrics"]
    virtual_network_subnet_ids = [azurerm_subnet.use2_sa_subnet.id]
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.use2_main_sa_identity.id,
    ]
  }

  sas_policy {
    expiration_period = "90.00:00:00"
    expiration_action = "Log"
  }

  lifecycle {
    ignore_changes = [
      customer_managed_key
    ]
  }
}

resource "azurerm_storage_container" "use2_main_batch_container" {
  #checkov:skip=CKV_AZURE_34:We want to allow public access to the container, we will serve static content from it
  name                  = "batch"
  storage_account_name  = azurerm_storage_account.use2_main_sa.name
  container_access_type = "blob"
}

resource "azurerm_key_vault_access_policy" "use2_main_sa_kv_access_policy" {
  key_vault_id       = azurerm_key_vault.use2_main_kv.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = azurerm_user_assigned_identity.use2_main_sa_identity.principal_id
  key_permissions    = ["Get", "Create", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

resource "azurerm_storage_account_customer_managed_key" "use2_main_sa_cmek" {
  storage_account_id        = azurerm_storage_account.use2_main_sa.id
  key_vault_id              = azurerm_key_vault.use2_main_kv.id
  key_name                  = azurerm_key_vault_key.use2_main_sa_kv_key.name
  user_assigned_identity_id = azurerm_user_assigned_identity.use2_main_sa_identity.id
  depends_on                = [azurerm_key_vault_access_policy.use2_main_sa_kv_access_policy]
}

resource "azurerm_log_analytics_storage_insights" "use2_sa_main_law_si" {
  name                = "${var.app_name}-${var.location_short}-${var.environment_name}-sa-law-si"
  resource_group_name = azurerm_resource_group.use2_main_rg.name
  workspace_id        = azurerm_log_analytics_workspace.use2_main_law.id
  storage_account_id  = azurerm_storage_account.use2_main_sa.id
  storage_account_key = azurerm_storage_account.use2_main_sa.primary_access_key
  blob_container_names = [
    azurerm_storage_container.use2_main_batch_container.name,
  ]
}

resource "azurerm_private_endpoint" "use2_main_sa_pe" {
  name                          = "${var.app_name}-${var.location_short}-${var.environment_name}-sa-pe"
  location                      = azurerm_resource_group.use2_main_rg.location
  resource_group_name           = azurerm_resource_group.use2_main_rg.name
  subnet_id                     = azurerm_subnet.use2_sa_subnet.id
  custom_network_interface_name = "${var.app_name}-${var.location_short}-${var.environment_name}-sa-pe-nic"
  tags                          = var.common_tags
  private_service_connection {
    name                           = "${var.app_name}-${var.location_short}-${var.environment_name}-sa-pe-connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.use2_main_sa.id
    subresource_names              = ["blob"]
  }
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

resource "azurerm_subnet" "use2_bp_subnet" {
  name                                      = "${var.app_name}-${var.location_short}-${var.environment_name}-bp-subnet"
  resource_group_name                       = azurerm_resource_group.use2_main_rg.name
  virtual_network_name                      = azurerm_virtual_network.use2_main_vnet.name
  address_prefixes                          = ["10.0.30.0/24"]
  private_endpoint_network_policies_enabled = false
  service_endpoints                         = ["Microsoft.Storage"]
}

resource "azurerm_network_security_group" "use2_bp_nsg" {
  #checkov:skip=CKV_AZURE_10:We need to allow ssh from the internet
  name                = "${var.app_name}-${var.location_short}-${var.environment_name}-bp-nsg"
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

resource "azurerm_subnet_network_security_group_association" "use2_bp_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.use2_bp_subnet.id
  network_security_group_id = azurerm_network_security_group.use2_bp_nsg.id
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
  data_disks {
    lun                  = 0
    disk_size_gb         = 10
    storage_account_type = "Standard_LRS"
  }
  # mount {
  #   azure_blob_file_system {
  #     account_name        = azurerm_storage_account.use2_main_sa.name
  #     container_name      = azurerm_storage_container.use2_main_batch_container.name
  #     relative_mount_path = "batch"
  #     account_key         = azurerm_storage_account.use2_main_sa.primary_access_key
  #   }
  # }
  network_configuration {
    subnet_id                        = azurerm_subnet.use2_bp_subnet.id
    public_address_provisioning_type = "NoPublicIPAddresses"
    accelerated_networking_enabled   = false
    dynamic_vnet_assignment_scope    = "none"
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
