# Azure DevOps Pipeline Setup Guide

This directory contains Azure DevOps pipeline YAML scripts for building, testing, and deploying the AppLibraryKit full-stack application to Azure.

## 📋 Contents

- **azure-pipelines-ci.yml** - Continuous Integration pipeline (Build, Test, Code Quality)
- **azure-pipelines-deploy.yml** - Deployment pipeline (Infrastructure & App Deployment)
- **terraform/** - Infrastructure as Code templates
  - `main.tf` - Azure resource definitions
  - `outputs.tf` - Terraform output configurations
  - `terraform.tfvars.example` - Example variable values
- **SERVICE_CONNECTION_SETUP.md** - Service connection configuration guide
- **QUICKSTART.md** - 5-minute setup guide

## 🚀 Quick Start

<<<<<<< HEAD
### Prerequisites
- Azure DevOps organization and project
- Azure subscription with Contributor role
- Git repository connected to Azure DevOps
- .NET 8 SDK and Node.js 18 installed locally (for testing)

### 1. Configure Azure Service Connection

Follow the [SERVICE_CONNECTION_SETUP.md](SERVICE_CONNECTION_SETUP.md) guide to:
1. Create Azure Service Principal
2. Add Service Connection in Azure DevOps
3. Grant necessary permissions

### 2. Configure Pipeline Variables

Add these variables in Azure DevOps Pipeline settings:

**Required Variables:**
```
AzureServiceConnection    = <ServiceConnectionName>
EnvironmentName          = prod
ProjectName              = applibrarykit
AzureSubscriptionId      = <YourSubscriptionId>
ResourceGroupName        = <ResourceGroupNameForInfra>
StorageAccountName       = <StorageAccountName>
AppServiceName           = <AppServiceName>
ReactAppApiBaseUrl       = https://<AppServiceName>.azurewebsites.net
```

**Backend State Variables (for Terraform):**
```
TfBackendResourceGroup   = terraform-state
TfBackendStorageAccount  = <TfStateStorageAccount>
TfBackendContainer       = tfstate
TfBackendKey             = applibrarykit.tfstate
```

### 3. Add Pipeline Files to Repository

Copy the pipeline YAML files to your repository:
```bash
# Copy CI pipeline
cp azure-pipelines-ci.yml <repo-root>/

# Copy deployment pipeline (optional, can use separate pipelines)
cp azure-pipelines-deploy.yml <repo-root>/

# Copy Terraform
cp -r terraform/ <repo-root>/DEPLOYMENT/AZUREPIPELINES/
```

### 4. Create Pipeline in Azure DevOps

**For CI Pipeline:**
1. Go to Azure DevOps → Pipelines → New Pipeline
2. Select "Existing Azure Pipelines YAML"
3. Select your repository
4. Choose `azure-pipelines-ci.yml`
5. Click "Save and run"

**For Deployment Pipeline (optional):**
1. Repeat steps above
2. Choose `azure-pipelines-deploy.yml`
3. Create separate pipeline or add as stage to CI pipeline

## 📊 Pipeline Architecture

### CI Pipeline (azure-pipelines-ci.yml)

**Stages:**
1. **BuildReactProduction** - Builds React app for production
2. **BuildDotNetProduction** - Builds .NET 8 API
3. **CodeQuality** - Runs code quality checks (SonarQube, tfsec)
4. **QualityGate** - Validates quality metrics

**Features:**
- Multi-job parallel execution
- ESLint for React code quality
- TypeScript compiler validation
- SonarQube analysis
- Terraform validation
- tfsec security scanning
- Artifact publishing

### Deployment Pipeline (azure-pipelines-deploy.yml)

**Stages:**
1. **BuildReactProduction** - Builds React for production
2. **BuildDotNetProduction** - Builds and publishes .NET API
3. **InfrastructureDeployment** - Terraform plan and apply
4. **DeployReactToStorage** - Uploads React app to Azure Storage
5. **DeployDotNetToAppService** - Deploys API to App Service
6. **DeploymentSummary** - Generates deployment report

**Features:**
- Terraform remote state management
- Blue-green-like deployments
- Health checks and validation
- CDN cache purging (if configured)
- Deployment summary report
- Artifact retention for rollback

## 🔧 Environment Setup

### Azure DevOps Project Settings

1. **Agents Pool:**
   - Pipelines use `ubuntu-latest` (Microsoft-hosted agent)
   - For private agents, create hosted pool with Ubuntu 22.04 LTS

2. **Pipeline Permissions:**
   - Service connection must have Contributor role on subscription
   - Set build job timeout to 60-90 minutes

3. **Retention:**
   - Build artifacts: 7 days
   - Pipeline runs: 30 days

### Terraform Backend (Optional)

For team collaboration, configure remote state:

```bash
# Create resource group
az group create -n terraform-state -l eastus

# Create storage account
az storage account create -n tfstate<unique> -g terraform-state -l eastus

# Create container
az storage container create -n tfstate --account-name tfstate<unique>
```

Update pipeline variables:
```
TfBackendResourceGroup = terraform-state
TfBackendStorageAccount = tfstate<unique>
```

## 📝 Variable Configuration

### Pipeline Variables File

Create `terraform/terraform.tfvars` from template:

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Edit with your values:
```hcl
subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
tenant_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
client_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
client_secret   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

environment = "prod"
location    = "eastus"
project_name = "applibrarykit"
```

**⚠️ Security Warning:** Never commit `terraform.tfvars` with secrets. Use Azure DevOps secret variables instead.

## 🔐 Secrets Management

### Store Secrets in Azure DevOps

1. Go to Pipelines → Settings → Variables
2. Add as secret variables (marked with 🔒):
   - `AzureClientSecret`
   - `JwtSecretKey`
   - Database connection strings
   - API keys

3. Reference in pipeline:
```yaml
env:
  JWT_SECRET: $(JwtSecretKey)
```

### Alternative: Azure Key Vault Integration

1. Create Azure Key Vault
2. Store secrets in Key Vault
3. Configure Service Connection to access Key Vault
4. Reference in pipeline:
```yaml
variables:
- group: 'KeyVault-Secrets'  # Linked variable group
```

## ✅ Quality Gates

### SonarQube Quality Gate

Configure in SonarQube project:
- Code Coverage: ≥ 80%
- Code Smells: 0
- Security Hotspots: 0
- Duplicated Lines: ≤ 3%
- Maintainability Rating: A

### tfsec Security Scanning

Validates Terraform security:
- No overly permissive security groups
- Encryption enabled on storage
- HTTPS enforced
- Key Vault access policies restricted

## 🚨 Troubleshooting

### Pipeline Fails at Terraform Stage

**Issue:** Terraform init fails with state file errors
```
Solution:
1. Check TfBackendResourceGroup, TfBackendStorageAccount variables
2. Verify storage account exists and has tfstate container
3. Ensure service connection has Storage Blob Contributor role
```

### Deploy Stage Skipped

**Issue:** Deployment stages show as skipped
```
Solution:
1. Check pipeline condition: dependsOn must match previous stage names
2. Verify BuildReactProduction and BuildDotNetProduction stages completed
3. Check resource artifact names match download task
```

### App Service Deployment Fails

**Issue:** AzureWebApp@1 task fails with 401 Unauthorized
```
Solution:
1. Verify App Service name in variables
2. Ensure service connection has Contributor role on App Service
3. Check publish artifact contains .zip file
4. Verify app.zip has correct .NET runtime dependencies
```

### SonarQube Analysis Timeout

**Issue:** SonarQube Analyze task times out
```
Solution:
1. Increase job timeout: set 'timeoutInMinutes: 120' in YAML
2. Reduce code analysis scope if analyzing 100k+ lines
3. Consider running SonarQube in separate scheduled pipeline
```

## 📊 Monitoring & Troubleshooting

### View Pipeline Logs

1. Azure DevOps → Pipelines → Pipeline Run
2. Click on stage/job to view logs
3. Use `task.debug: true` for verbose output

### Health Checks

Pipelines include health checks:
- Swagger endpoint: `GET https://<app-service>.azurewebsites.net/swagger`
- Storage account: Check blob container `$web`
- Key Vault: Verify secret access

## 🔄 CI/CD Workflow

### Commit Workflow

```
1. Developer commits to feature branch
2. (Optional) Manual trigger for feature branch testing
3. Create Pull Request → Runs CI pipeline
4. Code review and approval
5. Merge to main → Runs full deployment pipeline
6. Infrastructure provisioned/updated
7. Apps deployed to Azure
```

### Manual Deployment

To deploy manually without code changes:
```
Azure DevOps → Pipelines → Run pipeline → Queue
```

## 📚 Related Documentation

- [SERVICE_CONNECTION_SETUP.md](SERVICE_CONNECTION_SETUP.md) - Azure DevOps service connection setup
- [QUICKSTART.md](QUICKSTART.md) - 5-minute quick start guide
- [Terraform Documentation](terraform/README.md) - Infrastructure configuration details
- [GitHub Actions Guide](../../GITHUBWORKFLOWS/README.md) - Alternative CI/CD with GitHub Actions

## 🤝 Support

For issues or questions:
1. Check [Troubleshooting](#-troubleshooting) section
2. Review pipeline logs in Azure DevOps
3. Consult [Azure DevOps Documentation](https://docs.microsoft.com/en-us/azure/devops/)
4. Review [Terraform Azure Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

## 📄 License

Same license as parent AppLibraryKit project.
=======
See [QUICKSTART.md](QUICKSTART.md) for 5-minute setup instructions.

## 📚 Full Documentation

For detailed setup and troubleshooting:
1. [SERVICE_CONNECTION_SETUP.md](SERVICE_CONNECTION_SETUP.md) - Service connection configuration
2. [QUICKSTART.md](QUICKSTART.md) - 5-minute quick start
3. [README.md](README.md) - Complete setup guide
>>>>>>> 4c1262cb642ac2382ff24bab4ccb57c432b68bd3
