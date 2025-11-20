# =====================================================
# Terraform Outputs for Azure DevOps Pipeline
# =====================================================
# These outputs are exported as JSON and used by
# deployment pipeline for health checks and verification

output "resource_group_name" {
  value       = azurerm_resource_group.main.name
  description = "Name of the created resource group"
}

output "storage_account_name" {
  value       = azurerm_storage_account.spa.name
  description = "Name of the storage account for React SPA"
}

output "storage_account_primary_web_endpoint" {
  value       = azurerm_storage_account.spa.primary_web_endpoint
  description = "Primary web endpoint of the storage account"
}

output "storage_account_primary_web_host" {
  value       = replace(azurerm_storage_account.spa.primary_web_endpoint, "https://", "")
  description = "Hostname of the storage account website"
}

output "app_service_name" {
  value       = azurerm_linux_web_app.api.name
  description = "Name of the App Service hosting .NET API"
}

output "app_service_default_hostname" {
  value       = azurerm_linux_web_app.api.default_hostname
  description = "Default hostname of the App Service"
}

output "app_service_url" {
  value       = "https://${azurerm_linux_web_app.api.default_hostname}"
  description = "URL of the .NET API App Service"
}

output "app_insights_instrumentation_key" {
  value       = azurerm_application_insights.api.instrumentation_key
  description = "Instrumentation key for Application Insights"
  sensitive   = true
}

output "app_insights_connection_string" {
  value       = azurerm_application_insights.api.connection_string
  description = "Connection string for Application Insights"
  sensitive   = true
}

output "key_vault_id" {
  value       = azurerm_key_vault.main.id
  description = "ID of the Key Vault"
}

output "key_vault_name" {
  value       = azurerm_key_vault.main.name
  description = "Name of the Key Vault"
}

output "key_vault_uri" {
  value       = azurerm_key_vault.main.vault_uri
  description = "URI of the Key Vault"
}

output "log_analytics_workspace_id" {
  value       = azurerm_log_analytics_workspace.main.id
  description = "ID of the Log Analytics Workspace"
}

output "log_analytics_workspace_name" {
  value       = azurerm_log_analytics_workspace.main.name
  description = "Name of the Log Analytics Workspace"
}

output "deployment_summary" {
  value = {
    resource_group_name     = azurerm_resource_group.main.name
    region                  = var.location
    environment             = var.environment
    storage_account_name    = azurerm_storage_account.spa.name
    storage_web_endpoint    = azurerm_storage_account.spa.primary_web_endpoint
    app_service_name        = azurerm_linux_web_app.api.name
    app_service_hostname    = azurerm_linux_web_app.api.default_hostname
    app_insights_name       = azurerm_application_insights.api.name
    key_vault_name          = azurerm_key_vault.main.name
    log_analytics_workspace = azurerm_log_analytics_workspace.main.name
  }
  description = "Summary of all deployed resources"
}
