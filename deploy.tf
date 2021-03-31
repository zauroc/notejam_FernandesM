# Configure the Azure WEB APP with Deployment Slots 


data "azurerm_client_config" "currentjam" {}


resource "azurerm_resource_group" "slotsnotejam" {
    name = "rg-app-prod-001"
    location = "uksouth"
     tags = {
    environment = "production"
  }
}

# Deploying app service in Azure

resource "azurerm_app_service_plan" "slotsnotejampl" {
    name                = "appplan-uks-prod-001"
    location            = azurerm_resource_group.slotsnotejam.location
    resource_group_name = azurerm_resource_group.slotsnotejam.name
    sku {
        tier = "Standard"
        size = "S1"
    }
}

resource "azurerm_app_service" "slotsnotejamsvc" {
    name                = "appsv-uks-prod-001"
    location            = azurerm_resource_group.slotsnotejam.location
    resource_group_name = azurerm_resource_group.slotsnotejam.name
    app_service_plan_id = azurerm_app_service_plan.slotsnotejampl.id

  site_config {
    dotnet_framework_version = "v4.0"
  }
  
connection_string {
    name  = "Database"
    type  = "SQLAzure"
    value = "Server=tcp:azurerm_sql_server.sqldb.fully_qualified_domain_name Database=azurerm_sql_database.db.name;User ID=azurerm_sql_server.sqldb.administrator_login;Password=azurerm_sql_server.sqldb.administrator_login_password;Trusted_Connection=False;Encrypt=True;"
    
  }
}

resource "azurerm_app_service_slot" "slotsnotejamds" {
    name                = "app-notejam-dev-001"
    location            = azurerm_resource_group.slotsnotejam.location
    resource_group_name = azurerm_resource_group.slotsnotejam.name
    app_service_plan_id = azurerm_app_service_plan.slotsnotejampl.id
    app_service_name    = azurerm_app_service.slotsnotejamsvc.name
}
resource "azurerm_app_service_slot" "slotsnotejamuat" {
    name                = "app-notejam-uat-001"
    location            = azurerm_resource_group.slotsnotejam.location
    resource_group_name = azurerm_resource_group.slotsnotejam.name
    app_service_plan_id = azurerm_app_service_plan.slotsnotejampl.id
    app_service_name    = azurerm_app_service.slotsnotejamsvc.name
}

# Deploying SQL Database in Azure

resource "azurerm_storage_account" "slotsnotejamsa" {
  name                     = "stsqldbnotejam001"
  resource_group_name      = azurerm_resource_group.slotsnotejam.name
  location                 = azurerm_resource_group.slotsnotejam.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_sql_server" "slotsnotejamdbs" {
  name                         = "notejam-prod-sqlserver"
  resource_group_name          = azurerm_resource_group.slotsnotejam.name
  location                     = azurerm_resource_group.slotsnotejam.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
} 

resource "azurerm_mssql_database" "slotsnotejamdb" {
  name           = "sqldb-notejam-prod"
  server_id      = azurerm_sql_server.slotsnotejamdbs.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 4
  read_scale     = true
  sku_name       = "BC_Gen5_2"
  zone_redundant = true

  extended_auditing_policy {
    storage_endpoint                        = azurerm_storage_account.slotsnotejamsa.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.slotsnotejamsa.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 6
  }

  tags = {
    environment = "production"
  }
}

resource "azurerm_mssql_database" "slotsnotejamdbdev" {
  name           = "sqldb-notejam-dev"
  server_id      = azurerm_sql_server.slotsnotejamdbs.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 4
  read_scale     = true
  sku_name       = "BC_Gen5_2"
  zone_redundant = true

  extended_auditing_policy {
    storage_endpoint                        = azurerm_storage_account.slotsnotejamsa.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.slotsnotejamsa.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 6
  }

  tags = {
    environment = "development"
  }
}

resource "azurerm_mssql_database" "slotsnotejamdbuat" {
  name           = "sqldb-notejam-uat"
  server_id      = azurerm_sql_server.slotsnotejamdbs.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 4
  read_scale     = true
  sku_name       = "BC_Gen5_2"
  zone_redundant = true

  extended_auditing_policy {
    storage_endpoint                        = azurerm_storage_account.slotsnotejamsa.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.slotsnotejamsa.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 6
  }

  tags = {
    environment = "uat"
  }
}


# Deploying KeyValut in Azure

resource "azurerm_key_vault" "slotsnotejamkv" {
  name                        = "kv-uks-prod001"
  location                    = azurerm_resource_group.slotsnotejam.location
  resource_group_name         = azurerm_resource_group.slotsnotejam.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.currentjam.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.currentjam.tenant_id
    object_id = data.azurerm_client_config.currentjam.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

# Deploying LogAnalytics Workspace in Azure

resource "azurerm_log_analytics_workspace" "slotsnotejam" {
  name                = "logaworkspace-01"
  location            = azurerm_resource_group.slotsnotejam.location
  resource_group_name = azurerm_resource_group.slotsnotejam.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  }


