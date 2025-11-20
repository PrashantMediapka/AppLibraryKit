# =====================================================
# Terraform Variables Configuration Example
# =====================================================
# Copy this file to terraform.tfvars and update with
# your actual values before running terraform

# Azure Subscription Information
subscription_id = "f1944295-c875-4042-bb02-84b71e64719b"
tenant_id       = "8a54861f-10c8-463e-9302-c6ee5ca8350b"

# Service Principal Credentials
client_id     = "676e0a84-0d04-4cc4-b679-54fcd2e4f364"
client_secret = "YOUR_SERVICE_PRINCIPAL_CLIENT_SECRET"  

# Environment Configuration
environment = "prod"
location    = "eastus"

# Project Configuration
project_name = "applibrarykit"

# Resource SKUs and Tiers
app_service_sku                 = "B2"
storage_account_tier            = "Standard"
storage_account_replication_type = "GRS"

# Runtime Versions
dotnet_runtime_version = "8.0"
node_runtime_version   = "18"
