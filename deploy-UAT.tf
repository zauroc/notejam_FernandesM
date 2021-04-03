# Configure the Azure WEB APP with Deployment Slots 


data "azurerm_client_config" "currentjamu" {}


resource "azurerm_resource_group" "slotsnotejamu" {
    name = "rg-app-UAT-001"
    location = "uksouth"
     tags = {
    environment = "UAT"
  }
}

# Deploying app service in Azure

resource "azurerm_app_service_plan" "slotsnotejamplu" {
    name                = "appplan-uks-UAT-001"
    location            = azurerm_resource_group.slotsnotejamu.location
    resource_group_name = azurerm_resource_group.slotsnotejamu.name
    sku {
        tier = "Standard"
        size = "S1"
    }
}

resource "azurerm_app_service" "slotsnotejamsvcu" {
    name                = "appsv-uks-UAT-001"
    location            = azurerm_resource_group.slotsnotejamu.location
    resource_group_name = azurerm_resource_group.slotsnotejamu.name
    app_service_plan_id = azurerm_app_service_plan.slotsnotejamplu.id

  site_config {
    dotnet_framework_version = "v4.0"
  }
  
connection_string {
    name  = "Database"
    type  = "SQLAzure"
    value = "Server=tcp:azurerm_sql_server.sqldb.fully_qualified_domain_name Database=azurerm_sql_database.db.name;User ID=azurerm_sql_server.sqldb.administrator_login;Password=azurerm_sql_server.sqldb.administrator_login_password;Trusted_Connection=False;Encrypt=True;"
    
  }
}

resource "azurerm_app_service_slot" "slotsnotejamdsu" {
    name                = "app-notejam-stg-001"
    location            = azurerm_resource_group.slotsnotejamu.location
    resource_group_name = azurerm_resource_group.slotsnotejamu.name
    app_service_plan_id = azurerm_app_service_plan.slotsnotejamplu.id
    app_service_name    = azurerm_app_service.slotsnotejamsvcu.name
}
resource "azurerm_app_service_slot" "slotsnotejamlgu" {
    name                = "app-notejam-lgood-001"
    location            = azurerm_resource_group.slotsnotejamu.location
    resource_group_name = azurerm_resource_group.slotsnotejamu.name
    app_service_plan_id = azurerm_app_service_plan.slotsnotejamplu.id
    app_service_name    = azurerm_app_service.slotsnotejamsvcu.name
}

# Deploying SQL Database in Azure

resource "azurerm_storage_account" "slotsnotejamsau" {
  name                     = "stsqldbnotejam003"
  resource_group_name      = azurerm_resource_group.slotsnotejamu.name
  location                 = azurerm_resource_group.slotsnotejamu.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_sql_server" "slotsnotejamdbsu" {
  name                         = "notejam-uat-sqlserver"
  resource_group_name          = azurerm_resource_group.slotsnotejamu.name
  location                     = azurerm_resource_group.slotsnotejamu.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
} 

resource "azurerm_mssql_database" "slotsnotejamdbu" {
  name           = "sqldb-notejam-UAT"
  server_id      = azurerm_sql_server.slotsnotejamdbsu.id
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
    environment = "UAT"
  }
}

resource "azurerm_mssql_database" "slotsnotejamdbdevu" {
  name           = "sqldb-notejam-stg"
  server_id      = azurerm_sql_server.slotsnotejamdbsu.id
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
    environment = "Staging"
  }
}

resource "azurerm_mssql_database" "slotsnotejamdbuatu" {
  name           = "sqldb-notejam-lgood"
  server_id      = azurerm_sql_server.slotsnotejamdbsu.id
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
    environment = "LastGood"
  }
}


# Deploying KeyValut in Azure

resource "azurerm_key_vault" "slotsnotejamkvu" {
  name                        = "kv-uks-UAT001"
  location                    = azurerm_resource_group.slotsnotejamu.location
  resource_group_name         = azurerm_resource_group.slotsnotejamu.name
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

resource "azurerm_log_analytics_workspace" "slotsnotejamu" {
  name                = "logaworkspace-03"
  location            = azurerm_resource_group.slotsnotejamu.location
  resource_group_name = azurerm_resource_group.slotsnotejamu.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  }

# Deploying Application Insights in Azure

resource "azurerm_application_insights" "slotsnotejamaidu" {
  name                = "notejam-uat-appinsights"
  location            = azurerm_resource_group.slotsnotejamu.location
  resource_group_name = azurerm_resource_group.slotsnotejamu.name
  application_type    = "web"
}

#output "Instrumentation_key" {
  #value = azurerm_application_insights.slotsnotejamaidd.Instrumentation_key
#}

#output "appl_id" {
  #value = azurerm_application_insights.slotsnotejamaidd.appl_id
#}

# Deploying Auto-Scaling for App Service in Azure

resource "azurerm_monitor_autoscale_setting" "autoscale_setting2" {
  name                = "myAutoscaleSetting"
  resource_group_name = azurerm_resource_group.slotsnotejamu.name
  location            = azurerm_resource_group.slotsnotejamu.location
  target_resource_id  = azurerm_app_service_plan.slotsnotejamplu.id

  profile {
    name = "CpuProfile"

    capacity {
      default = 1
      minimum = 1
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_app_service_plan.slotsnotejamplu.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_app_service_plan.slotsnotejamplu.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator    = false
      send_to_subscription_co_administrator = false
    }
  }
}

# Deploying Monitoring in Azure

resource "azurerm_storage_account" "to_monitor_uat" {
  name                     = "azmonitorsa003"
  resource_group_name      = azurerm_resource_group.slotsnotejamu.name
  location                 = azurerm_resource_group.slotsnotejamu.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_monitor_action_group" "main2" {
  name                = "notejam-actiongroup"
  resource_group_name = azurerm_resource_group.slotsnotejamu.name
  short_name          = "notejamact"

  webhook_receiver {
    name        = "callmyapi"
    service_uri = "http://notejam.com/alert"
  }
}

resource "azurerm_monitor_metric_alert" "alertu" {
  name                = "notejam-metricalert"
  resource_group_name = azurerm_resource_group.slotsnotejamu.name
  scopes              = [azurerm_storage_account.to_monitor_uat.id]
  description         = "Action will be triggered when Transactions count is greater than 50."

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "Transactions"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 50

    dimension {
      name     = "ApiName"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.main2.id
  }
}