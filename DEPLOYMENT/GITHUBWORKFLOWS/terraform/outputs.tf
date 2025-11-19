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

output "app_service_name" {
  value       = azurerm_linux_web_app.api.name
  description = "Name of the App Service hosting .NET API"
}

output "app_service_default_hostname" {
  value       = azurerm_linux_web_app.api.default_hostname
  description = "Default hostname of the App Service"
}

output "app_service_default_url" {
  value       = "https://${azurerm_linux_web_app.api.default_hostname}"
  description = "Full URL of the .NET API"
}

output "app_insights_connection_string" {
  value       = azurerm_application_insights.api.connection_string
  description = "Connection string for Application Insights"
  sensitive   = true
}

output "app_insights_instrumentation_key" {
  value       = azurerm_application_insights.api.instrumentation_key
  description = "Instrumentation key for Application Insights"
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

output "log_analytics_workspace_id" {
  value       = azurerm_log_analytics_workspace.main.id
  description = "ID of the Log Analytics Workspace"
}

output "spa_url" {
  value       = azurerm_storage_account.spa.primary_web_endpoint
  description = "URL to access the React SPA"
}

output "api_url" {
  value       = "https://${azurerm_linux_web_app.api.default_hostname}"
  description = "URL to access the .NET 8 API"
}

output "swagger_url" {
  value       = "https://${azurerm_linux_web_app.api.default_hostname}/swagger"
  description = "Swagger UI endpoint for the API"
<<<<<<< HEAD
}
=======
}
>>>>>>> 4c1262cb642ac2382ff24bab4ccb57c432b68bd3
