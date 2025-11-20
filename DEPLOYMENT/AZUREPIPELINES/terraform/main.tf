// Terraform Configuration for AppLibraryKit
// This Terraform configuration provisions:
// - Resource Group
// - Storage account (static website for React SPA)
// - App Service Plan and Linux Web App (for .NET 8 API)
// - Application Insights
// - Key Vault and a sample secret
// - Log Analytics Workspace

terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

provider "random" {}

// Variables
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "applibrarykit"
}

variable "app_service_sku" {
  description = "SKU for App Service Plan"
  type        = string
  default     = "B2"  # Basic B1, B2, B3; Standard S1, S2, S3
}

variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "GRS"
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "client_id" {
  description = "Azure Service Principal Client ID"
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Azure Service Principal Client Secret"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
  sensitive   = true
}

variable "dotnet_runtime_version" {
  description = ".NET runtime version"
  type        = string
  default     = "8.0"
}

variable "node_runtime_version" {
  description = "Node.js runtime version for Static Web Apps"
  type        = string
  default     = "18"
}

// Local Variables
locals {
  resource_prefix = "${var.project_name}-${var.environment}"
  
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    CreatedAt   = timestamp()
  }
}

// Random String for Uniqueness
resource "random_string" "resource_suffix" {
  length  = 4
  special = false
  upper   = false
}

// Resource Group
resource "azurerm_resource_group" "main" {
  # Explicit resource group name per request
  name       = "rgapplibdemo"
  location   = var.location
  tags       = local.common_tags
}

// Storage Account (for React SPA)
resource "azurerm_storage_account" "spa" {
  # Explicit storage account name per request (must be globally unique and 3-24 lowercase alphanumeric)
  name                     = "stapplibdemo001"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  https_traffic_only_enabled = true

  static_website {
    index_document     = "index.html"
    error_404_document = "index.html"
  }

  tags = local.common_tags
}

// Storage container for static website
resource "azurerm_storage_container" "spa_web" {
  name                  = "$web"
  storage_account_id    = azurerm_storage_account.spa.id
  container_access_type = "blob"
}

// App Service Plan (for .NET 8 API)
resource "azurerm_service_plan" "api" {
  name                = "${local.resource_prefix}-api-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = var.app_service_sku

  tags = local.common_tags
}

// App Service (.NET 8 Web API)
resource "azurerm_linux_web_app" "api" {
  name                = "${local.resource_prefix}-api"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.api.id

  site_config {
    application_stack {
      dotnet_version = var.dotnet_runtime_version
    }
    
    always_on         = true
    http2_enabled     = true
    websockets_enabled = false
    minimum_tls_version = "1.2"
    
    cors {
      allowed_origins = [
        "https://${azurerm_storage_account.spa.primary_web_endpoint}",
        "http://localhost:3000",
        "http://localhost:3001"
      ]
      support_credentials = true
    }
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"      = "1"
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "XDT_MakeFileInPlace"           = "0"
    "APPINSIGHTS_PROFILER_ENABLED"  = "true"
  }

  https_only = true
  
  tags = local.common_tags
}

// Application Insights (Monitoring)
resource "azurerm_application_insights" "api" {
  name                = "${local.resource_prefix}-appinsights"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
  sampling_percentage = 100

  tags = local.common_tags
}

// Key Vault (Secrets Management)
resource "azurerm_key_vault" "main" {
  # Explicit Key Vault name per request
  name                        = "kvapplibdemo"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
      "List",
      "Create",
      "Delete",
    ]

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
    ]
  }

  tags = local.common_tags
}

// Key Vault Secret for JWT Secret Key
resource "azurerm_key_vault_secret" "jwt_secret" {
  name         = "JwtSecretKey"
  value        = "SuperSecureJwtKey1234567890123456789"  # Replace with actual secret
  key_vault_id = azurerm_key_vault.main.id

  tags = local.common_tags
}

// ============================================
// Cosmos DB Account (requested: cosapplibdemo001)
// ============================================
resource "azurerm_cosmosdb_account" "main" {
  name                = "cosapplibdemo001"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.main.location
    failover_priority = 0
  }

 // capabilities = []

 // enable_automatic_failover = false
 // enable_multiple_write_locations = false

  tags = local.common_tags
}

// Note: a separate Azure Static Web App resource is not used here.
// The React SPA will be hosted using the Storage Account static website feature
// created above (`stapplibdemo001`). The requested static app name `swapplibdemo001`
// will be represented by the storage account's static website endpoint.

// Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${local.resource_prefix}-logs"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.common_tags
}

// Data Source: Current Client Config
data "azurerm_client_config" "current" {}

// Outputs
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

output "static_app_name" {
  value       = "swapplibdemo001"
  description = "Logical static app name requested; hosted via the storage account static website stapplibdemo001"
}

output "static_app_url" {
  value       = azurerm_storage_account.spa.primary_web_endpoint
  description = "URL to access the static web app (storage static website)"
}

output "app_service_name" {
  value       = azurerm_linux_web_app.api.name
  description = "Name of the App Service hosting .NET API"
}

output "app_service_default_hostname" {
  value       = azurerm_linux_web_app.api.default_hostname
  description = "Default hostname of the App Service"
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

output "log_analytics_workspace_id" {
  value       = azurerm_log_analytics_workspace.main.id
  description = "ID of the Log Analytics Workspace"
}
