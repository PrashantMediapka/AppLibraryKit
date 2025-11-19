<<<<<<< HEAD
# ============================================\n# Terraform Configuration for AppLibraryKit\n# ============================================\n# This Terraform configuration provisions:\n# 1. Resource Groups\n# 2. Azure Storage Account (for React SPA)\n# 3. Azure App Service (for .NET 8 Web API)\n# 4. Application Insights (for monitoring)\n# 5. KeyVault (for secrets management)\n\nterraform {\n  required_version = \">= 1.0.0\"\n  \n  required_providers {\n    azurerm = {\n      source  = \"hashicorp/azurerm\"\n      version = \"~> 3.80.0\"\n    }\n    random = {\n      source  = \"hashicorp/random\"\n      version = \"~> 3.5.0\"\n    }\n  }\n\n  # Backend configuration (comment out for local state, uncomment for remote)\n  # backend \"azurerm\" {\n  #   resource_group_name  = \"terraform-state\"\n  #   storage_account_name = \"tfstate\"\n  #   container_name       = \"tfstate\"\n  #   key                  = \"applibrarykit.tfstate\"\n  # }\n}\n\nprovider \"azurerm\" {\n  features {\n    key_vault {\n      purge_soft_delete_on_destroy    = true\n      recover_soft_deleted_key_vaults = true\n    }\n  }\n}\n\nprovider \"random\" {}\n\n# ============================================\n# Variables\n# ============================================\nvariable \"environment\" {\n  description = \"Environment name (dev, staging, prod)\"\n  type        = string\n  default     = \"prod\"\n}\n\nvariable \"location\" {\n  description = \"Azure region for resources\"\n  type        = string\n  default     = \"eastus\"\n}\n\nvariable \"project_name\" {\n  description = \"Project name\"\n  type        = string\n  default     = \"applibrarykit\"\n}\n\nvariable \"app_service_sku\" {\n  description = \"SKU for App Service Plan\"\n  type        = string\n  default     = \"B2\"  # Basic B1, B2, B3; Standard S1, S2, S3\n}\n\nvariable \"storage_account_tier\" {\n  description = \"Storage account tier\"\n  type        = string\n  default     = \"Standard\"\n}\n\nvariable \"storage_account_replication_type\" {\n  description = \"Storage account replication type\"\n  type        = string\n  default     = \"GRS\"\n}\n\nvariable \"subscription_id\" {\n  description = \"Azure Subscription ID\"\n  type        = string\n  sensitive   = true\n}\n\nvariable \"client_id\" {\n  description = \"Azure Service Principal Client ID\"\n  type        = string\n  sensitive   = true\n}\n\nvariable \"client_secret\" {\n  description = \"Azure Service Principal Client Secret\"\n  type        = string\n  sensitive   = true\n}\n\nvariable \"tenant_id\" {\n  description = \"Azure Tenant ID\"\n  type        = string\n  sensitive   = true\n}\n\nvariable \"dotnet_runtime_version\" {\n  description = \".NET runtime version\"\n  type        = string\n  default     = \"8.0\"\n}\n\nvariable \"node_runtime_version\" {\n  description = \"Node.js runtime version for Static Web Apps\"\n  type        = string\n  default     = \"18\"\n}\n\n# ============================================\n# Local Variables\n# ============================================\nlocals {\n  resource_prefix = \"${var.project_name}-${var.environment}\"\n  \n  common_tags = {\n    Environment = var.environment\n    Project     = var.project_name\n    ManagedBy   = \"Terraform\"\n    CreatedAt   = timestamp()\n  }\n}\n\n# ============================================\n# Random String for Uniqueness\n# ============================================\nresource \"random_string\" \"resource_suffix\" {\n  length  = 4\n  special = false\n  upper   = false\n}\n\n# ============================================\n# Resource Group\n# ============================================\nresource \"azurerm_resource_group\" \"main\" {\n  name       = \"${local.resource_prefix}-rg\"\n  location   = var.location\n  tags       = local.common_tags\n}\n\n# ============================================\n# Storage Account (for React SPA)\n# ============================================\nresource \"azurerm_storage_account\" \"spa\" {\n  name                     = \"${replace(local.resource_prefix, \"-\", \"\")}${random_string.resource_suffix.result}\"\n  resource_group_name      = azurerm_resource_group.main.name\n  location                 = azurerm_resource_group.main.location\n  account_tier             = var.storage_account_tier\n  account_replication_type = var.storage_account_replication_type\n  https_traffic_only_enabled = true\n\n  static_website {\n    index_document     = \"index.html\"\n    error_404_document = \"index.html\"\n  }\n\n  tags = local.common_tags\n}\n\n# Storage container for static website\nresource \"azurerm_storage_container\" \"spa_web\" {\n  name                  = \"$web\"\n  storage_account_id    = azurerm_storage_account.spa.id\n  container_access_type = \"blob\"\n}\n\n# ============================================\n# App Service Plan (for .NET 8 API)\n# ============================================\nresource \"azurerm_service_plan\" \"api\" {\n  name                = \"${local.resource_prefix}-api-plan\"\n  location            = azurerm_resource_group.main.location\n  resource_group_name = azurerm_resource_group.main.name\n  os_type             = \"Linux\"\n  sku_name            = var.app_service_sku\n\n  tags = local.common_tags\n}\n\n# ============================================\n# App Service (.NET 8 Web API)\n# ============================================\nresource \"azurerm_linux_web_app\" \"api\" {\n  name                = \"${local.resource_prefix}-api\"\n  location            = azurerm_resource_group.main.location\n  resource_group_name = azurerm_resource_group.main.name\n  service_plan_id     = azurerm_service_plan.api.id\n\n  site_config {\n    application_stack {\n      dotnet_version = var.dotnet_runtime_version\n    }\n    \n    always_on         = true\n    http2_enabled     = true\n    websockets_enabled = false\n    minimum_tls_version = \"1.2\"\n    \n    cors {\n      allowed_origins = [\n        \"https://${azurerm_storage_account.spa.primary_web_endpoint}\",\n        \"http://localhost:3000\",\n        \"http://localhost:3001\"\n      ]\n      support_credentials = true\n    }\n  }\n\n  app_settings = {\n    \"WEBSITE_RUN_FROM_PACKAGE\"      = \"1\"\n    \"ApplicationInsightsAgent_EXTENSION_VERSION\" = \"~3\"\n    \"XDT_MakeFileInPlace\"           = \"0\"\n    \"APPINSIGHTS_PROFILER_ENABLED\"  = \"true\"\n  }\n\n  https_only = true\n  \n  tags = local.common_tags\n}\n\n# ============================================\n# Application Insights (Monitoring)\n# ============================================\nresource \"azurerm_application_insights\" \"api\" {\n  name                = \"${local.resource_prefix}-appinsights\"\n  location            = azurerm_resource_group.main.location\n  resource_group_name = azurerm_resource_group.main.name\n  application_type    = \"web\"\n  sampling_percentage = 100\n\n  tags = local.common_tags\n}\n\n# ============================================\n# Key Vault (Secrets Management)\n# ============================================\nresource \"azurerm_key_vault\" \"main\" {\n  name                        = \"${replace(local.resource_prefix, \"-\", \"\")}${random_string.resource_suffix.result}-kv\"\n  location                    = azurerm_resource_group.main.location\n  resource_group_name         = azurerm_resource_group.main.name\n  enabled_for_disk_encryption = true\n  tenant_id                   = data.azurerm_client_config.current.tenant_id\n  sku_name                    = \"standard\"\n\n  access_policy {\n    tenant_id = data.azurerm_client_config.current.tenant_id\n    object_id = data.azurerm_client_config.current.object_id\n\n    key_permissions = [\n      \"Get\",\n      \"List\",\n      \"Create\",\n      \"Delete\",\n    ]\n\n    secret_permissions = [\n      \"Get\",\n      \"List\",\n      \"Set\",\n      \"Delete\",\n    ]\n  }\n\n  tags = local.common_tags\n}\n\n# Key Vault Secret for JWT Secret Key\nresource \"azurerm_key_vault_secret\" \"jwt_secret\" {\n  name         = \"JwtSecretKey\"\n  value        = \"SuperSecureJwtKey1234567890123456789\"  # Replace with actual secret\n  key_vault_id = azurerm_key_vault.main.id\n\n  tags = local.common_tags\n}\n\n# ============================================\n# Log Analytics Workspace\n# ============================================\nresource \"azurerm_log_analytics_workspace\" \"main\" {\n  name                = \"${local.resource_prefix}-logs\"\n  location            = azurerm_resource_group.main.location\n  resource_group_name = azurerm_resource_group.main.name\n  sku                 = \"PerGB2018\"\n  retention_in_days   = 30\n\n  tags = local.common_tags\n}\n\n# ============================================\n# Data Source: Current Client Config\n# ============================================\ndata \"azurerm_client_config\" \"current\" {}\n\n# ============================================\n# Outputs\n# ============================================\noutput \"resource_group_name\" {\n  value       = azurerm_resource_group.main.name\n  description = \"Name of the created resource group\"\n}\n\noutput \"storage_account_name\" {\n  value       = azurerm_storage_account.spa.name\n  description = \"Name of the storage account for React SPA\"\n}\n\noutput \"storage_account_primary_web_endpoint\" {\n  value       = azurerm_storage_account.spa.primary_web_endpoint\n  description = \"Primary web endpoint of the storage account\"\n}\n\noutput \"app_service_name\" {\n  value       = azurerm_linux_web_app.api.name\n  description = \"Name of the App Service hosting .NET API\"\n}\n\noutput \"app_service_default_hostname\" {\n  value       = azurerm_linux_web_app.api.default_hostname\n  description = \"Default hostname of the App Service\"\n}\n\noutput \"app_insights_connection_string\" {\n  value       = azurerm_application_insights.api.connection_string\n  description = \"Connection string for Application Insights\"\n  sensitive   = true\n}\n\noutput \"key_vault_id\" {\n  value       = azurerm_key_vault.main.id\n  description = \"ID of the Key Vault\"\n}\n\noutput \"log_analytics_workspace_id\" {\n  value       = azurerm_log_analytics_workspace.main.id\n  description = \"ID of the Log Analytics Workspace\"\n}\n"
=======
# Terraform Configuration for AppLibraryKit
# This configuration provisions Azure resources for React SPA and .NET 8 API

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

# Variables
variable "environment" {
  type    = string
  default = "prod"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "project_name" {
  type    = string
  default = "applibrarykit"
}

variable "app_service_sku" {
  type    = string
  default = "B2"
}

variable "storage_account_tier" {
  type    = string
  default = "Standard"
}

variable "storage_account_replication_type" {
  type    = string
  default = "GRS"
}

variable "subscription_id" {
  type      = string
  sensitive = true
}

variable "client_id" {
  type      = string
  sensitive = true
}

variable "client_secret" {
  type      = string
  sensitive = true
}

variable "tenant_id" {
  type      = string
  sensitive = true
}

variable "dotnet_runtime_version" {
  type    = string
  default = "8.0"
}

variable "node_runtime_version" {
  type    = string
  default = "18"
}

# Local variables
locals {
  resource_prefix = "${var.project_name}-${var.environment}"
  
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Random suffix for unique names
resource "random_string" "resource_suffix" {
  length  = 4
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${local.resource_prefix}-rg"
  location = var.location
  tags     = local.common_tags
}

# Storage Account for React SPA
resource "azurerm_storage_account" "spa" {
  name                     = "${replace(local.resource_prefix, "-", "")}${random_string.resource_suffix.result}"
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

# Storage container for static website
resource "azurerm_storage_container" "spa_web" {
  name                  = "$web"
  storage_account_id    = azurerm_storage_account.spa.id
  container_access_type = "blob"
}

# App Service Plan for .NET 8 API
resource "azurerm_service_plan" "api" {
  name                = "${local.resource_prefix}-api-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = var.app_service_sku

  tags = local.common_tags
}

# App Service (.NET 8 Web API)
resource "azurerm_linux_web_app" "api" {
  name                = "${local.resource_prefix}-api"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.api.id

  site_config {
    application_stack {
      dotnet_version = var.dotnet_runtime_version
    }
    
    always_on          = true
    http2_enabled      = true
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

  https_only = true
  
  tags = local.common_tags
}

# Application Insights
resource "azurerm_application_insights" "api" {
  name                = "${local.resource_prefix}-appinsights"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
  sampling_percentage = 100

  tags = local.common_tags
}

# Key Vault
resource "azurerm_key_vault" "main" {
  name                        = "${replace(local.resource_prefix, "-", "")}${random_string.resource_suffix.result}-kv"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = ["Get", "List", "Create", "Delete"]
    secret_permissions = ["Get", "List", "Set", "Delete"]
  }

  tags = local.common_tags
}

# Key Vault Secret for JWT
resource "azurerm_key_vault_secret" "jwt_secret" {
  name         = "JwtSecretKey"
  value        = "SuperSecureJwtKey1234567890123456789"
  key_vault_id = azurerm_key_vault.main.id

  tags = local.common_tags
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${local.resource_prefix}-logs"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.common_tags
}

# Current Client Config
data "azurerm_client_config" "current" {}

# Outputs
output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "storage_account_name" {
  value = azurerm_storage_account.spa.name
}

output "storage_primary_web_endpoint" {
  value = azurerm_storage_account.spa.primary_web_endpoint
}

output "app_service_name" {
  value = azurerm_linux_web_app.api.name
}

output "app_service_url" {
  value = "https://${azurerm_linux_web_app.api.default_hostname}"
}

output "key_vault_name" {
  value = azurerm_key_vault.main.name
}
>>>>>>> 4c1262cb642ac2382ff24bab4ccb57c432b68bd3
