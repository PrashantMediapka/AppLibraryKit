<<<<<<< HEAD
# GitHub Workflows for AppLibraryKit Deployment

This directory contains comprehensive GitHub Actions workflows for building, testing, code quality checks, and deploying both the React frontend and .NET 8 API backend to Azure.

## 📋 Workflows Overview

### 1. **CI Build & Quality** (`ci-build-quality.yml`)
Runs on every push to `main` and `develop` branches, plus all pull requests.

**Jobs:**
- **build-react**: Build React SPA with ESLint, TypeScript checks, tests
- **build-dotnet**: Build .NET 8 API with unit tests and code analysis
- **validate-terraform**: Validate Terraform configurations
- **quality-gate**: Summarize build results

**Features:**
- ✅ Node.js 18 caching for faster builds
- ✅ .NET 8 caching for dependencies
- ✅ TypeScript compilation check
- ✅ ESLint static analysis
- ✅ Unit testing with coverage
- ✅ Terraform format validation
- ✅ Security scanning (tfsec)
- ✅ Optional SonarQube integration

---

### 2. **Deploy to Azure** (`deploy-azure.yml`)
Manually triggered via `workflow_dispatch` or automatically on push to `main` (if changes detected).

**Jobs:**
1. **build-publish-react**: Build optimized React production bundle
2. **build-publish-dotnet**: Publish .NET API for deployment
3. **terraform-deploy**: Provision infrastructure with Terraform
4. **deploy-react-azure**: Upload React build to Azure Storage ($web container)
5. **deploy-dotnet-azure**: Deploy .NET API to Azure App Service
6. **deployment-summary**: Generate summary and send notifications

**Features:**
- ✅ Artifact management between jobs
- ✅ Azure authentication via service principal
- ✅ Terraform state backend support
- ✅ Automatic CDN cache purge
- ✅ Health check validation
- ✅ Optional Slack notifications

---

## 🔐 Required GitHub Secrets

Before running the workflows, add these secrets to your GitHub repository:

### Azure Credentials
```
AZURE_SUBSCRIPTION_ID      # Azure subscription ID
AZURE_TENANT_ID            # Azure AD tenant ID
AZURE_CLIENT_ID            # Service principal app ID
AZURE_CLIENT_SECRET        # Service principal password
```

### Azure Resources
```
AZURE_STORAGE_ACCOUNT      # Storage account name for React
AZURE_RESOURCE_GROUP       # Resource group name
AZURE_APPSERVICE_NAME      # App Service name for .NET API
```

### Terraform Backend (Optional)
```
TF_BACKEND_RG              # Resource group for Terraform state
TF_BACKEND_SA              # Storage account for Terraform state
TF_BACKEND_CONTAINER       # Container name for Terraform state
TF_BACKEND_KEY             # State file name (e.g., applibrarykit.tfstate)
```

### Optional
```
REACT_APP_API_BASE_URL     # API endpoint for React (e.g., https://api.azurewebsites.net)
SONAR_TOKEN                # SonarQube token (if using SonarCloud)
SLACK_WEBHOOK_URL          # Slack webhook for notifications
AZURE_CDN_PROFILE          # CDN profile name (for cache purge)
AZURE_CDN_ENDPOINT         # CDN endpoint name
```

---

## 🏗️ Terraform Configuration

### Files
- **main.tf**: Primary configuration (resource groups, storage, app service, key vault)
- **variables.tf**: Variable declarations
- **outputs.tf**: Output values
- **terraform.tfvars.example**: Example values

### Resources Provisioned

#### Resource Group
- Central resource group for all infrastructure

#### Storage Account (React SPA)
- Static website hosting enabled
- HTTPS only
- Global Replication Store (GRS)
- $web container for index.html and assets

#### App Service Plan & Linux Web App (.NET API)
- Linux-based App Service
- .NET 8 runtime
- CORS configured for React origins
- Application Insights enabled
- HTTPS enforced
- Always-on enabled

#### Application Insights
- Performance monitoring
- Log analytics
- Exception tracking

#### Key Vault
- Secrets management
- JWT secret storage
- Managed identity ready

#### Log Analytics Workspace
- Centralized logging
- 30-day retention

---

## 🚀 Deployment Flow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Push to main / Manual Trigger (workflow_dispatch)       │
└───────────────────────┬─────────────────────────────────────┘
                        │
        ┌───────────────┴───────────────┐
        │                               │
    ┌───▼────────────────┐     ┌────────▼──────────────┐
    │ Build React SPA    │     │ Build .NET 8 API     │
    │ (npm build)        │     │ (dotnet publish)     │
    └───┬────────────────┘     └────────┬──────────────┘
        │                               │
        └───────────────┬───────────────┘
                        │
                    ┌───▼──────────────────┐
                    │ Terraform Deploy     │
                    │ (Init → Plan → Apply)│
                    └───┬──────────────────┘
                        │
        ┌───────────────┴───────────────┐
        │                               │
    ┌───▼─────────────────────┐  ┌─────▼──────────────────┐
    │ Deploy React to Storage │  │ Deploy .NET to App     │
    │ (az storage blob        │  │ Service (azure/        │
    │  upload-batch)          │  │ webapps-deploy)        │
    └───┬─────────────────────┘  └─────┬──────────────────┘
        │                               │
        └───────────────┬───────────────┘
                        │
                    ┌───▼──────────────────┐
                    │ Deployment Summary   │
                    │ + Notifications      │
                    └──────────────────────┘
```

---

## 📝 Usage Examples

### Manual Deployment
```yaml
# Trigger deployment workflow manually
1. Go to GitHub Actions
2. Select "Deploy to Azure"
3. Click "Run workflow"
4. Choose branch (usually 'main')
5. Click "Run workflow"
```

### Automatic Deployment
```yaml
# Automatically deploys when changes are pushed to main
# in APPS/ or DEPLOYMENT/GITHUBWORKFLOWS/terraform/ directories
```

### CI Checks Only
```yaml
# Runs on every push and PR to main/develop
# No deployment happens
```

---

## 🔧 Configuration Details

### Terraform Variables
In `deploy-azure.yml`, variables are passed as:

```yaml
terraform plan \
  -var="subscription_id=${{ env.AZURE_SUBSCRIPTION_ID }}" \
  -var="client_id=${{ env.AZURE_CLIENT_ID }}" \
  -var="client_secret=${{ env.AZURE_CLIENT_SECRET }}" \
  -var="tenant_id=${{ env.AZURE_TENANT_ID }}"
```

Override defaults in GitHub Actions:
```yaml
-var="app_service_sku=B3"
-var="location=westus2"
-var="environment=staging"
```

### Environment-Specific Deployment
Create separate workflow files or branch conditions:

```yaml
# For staging environment
on:
  push:
    branches: [ develop ]

env:
  ENVIRONMENT: staging
  TF_BACKEND_KEY: applibrarykit-staging.tfstate
```

---

## 🔍 Code Quality Checks

### React
- **ESLint**: JavaScript/TypeScript linting
- **TypeScript**: Type checking (`tsc --noEmit`)
- **Testing**: Jest test execution
- **Coverage**: Test coverage reports

### .NET
- **Build Analysis**: Compiler warnings
- **StyleCop**: Code style enforcement
- **Tests**: xUnit/NUnit tests
- **Code Metrics**: Coverage and complexity

### Terraform
- **Format Check**: `terraform fmt -check`
- **Validation**: `terraform validate`
- **Security**: tfsec for security issues

---

## 📊 Monitoring & Logging

### GitHub Actions
- Workflow logs: GitHub Actions tab
- Artifact downloads: Available for 7 days
- Deployment history: Actions > Deployments

### Azure
- App Service logs: Azure Portal > App Service > Logs
- Application Insights: Query performance, exceptions
- Log Analytics: Centralized logging

### Notifications
- GitHub Actions status badges
- Slack channel notifications (if configured)
- Email from GitHub (branch protections)

---

## 🛠️ Troubleshooting

### Terraform State Issues
**Problem**: `Error: Error acquiring the lock`

**Solution**:
```bash
# Reset state lock (careful!)
az storage blob lease break \
  --account-name <storage-account> \
  --container-name <container> \
  --blob-name <key>
```

### Deployment Failures
**Check logs**:
1. GitHub Actions workflow logs
2. Azure App Service logs
3. Application Insights

**Common issues**:
- CORS misconfiguration
- Missing environment variables
- Insufficient Azure RBAC permissions
- Storage account not accessible

### Build Failures
**React**:
```bash
# Clear cache and rebuild locally
rm -rf node_modules package-lock.json
npm install
npm run build
```

**.NET**:
```bash
# Clear build artifacts
dotnet clean
dotnet restore
dotnet build
```

---

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure CLI Documentation](https://learn.microsoft.com/en-us/cli/azure/)
- [React Deployment to Azure Storage](https://learn.microsoft.com/en-us/azure/storage/blobs/static-website-how-to-use?tabs=azure-cli)

---

## 📞 Support

For issues or improvements, open a GitHub issue or contact the development team.

---

**Last Updated**: November 2025
**Version**: 1.0
=======
# GitHub Workflows for AppLibraryKit

Comprehensive GitHub Actions workflows for building, testing, and deploying both React SPA and .NET 8 API to Azure.

## 📋 Included Workflows

- **ci-build-quality.yml**: Build, test, and code quality checks
- **deploy-azure.yml**: Infrastructure provisioning and deployment
- **Terraform configs**: Azure resource definitions

See README.md for full documentation.
>>>>>>> 4c1262cb642ac2382ff24bab4ccb57c432b68bd3
