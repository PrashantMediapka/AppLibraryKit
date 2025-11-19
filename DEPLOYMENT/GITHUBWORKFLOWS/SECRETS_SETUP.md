# GitHub Secrets Setup Guide

<<<<<<< HEAD
This guide helps you configure all required GitHub repository secrets for the CI/CD workflows.

## 📋 Prerequisites

1. **Azure Subscription** with active service principal
2. **GitHub Repository** with Actions enabled
3. **Azure CLI** installed locally
4. **Repository Admin** access

---

## 🔐 Step-by-Step Setup

### Step 1: Create Azure Service Principal

If you don't have a service principal, create one:

```bash
# Login to Azure
az login

# Get subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "Subscription ID: $SUBSCRIPTION_ID"

# Create service principal
az ad sp create-for-rbac \
  --name "github-actions-applibrarykit" \
  --role "Contributor" \
  --scopes "/subscriptions/$SUBSCRIPTION_ID" \
  --output json
```

**Save the output** - you'll need these values:
```json
{
  "appId": "AZURE_CLIENT_ID",
  "password": "AZURE_CLIENT_SECRET",
  "tenant": "AZURE_TENANT_ID"
}
```

---

### Step 2: Get Tenant ID and Subscription ID

```bash
# Get Tenant ID
TENANT_ID=$(az account show --query tenantId -o tsv)
echo "Tenant ID: $TENANT_ID"

# Get Subscription ID (if not already captured)
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "Subscription ID: $SUBSCRIPTION_ID"
```

---

### Step 3: Create Azure Resources (if not exists)

```bash
# Create resource group
az group create \
  --name applibrarykit-prod-rg \
  --location eastus

# Create storage account (for Terraform state backend)
az storage account create \
  --name applibraryktftstate \
  --resource-group applibrarykit-prod-rg \
  --location eastus \
  --sku Standard_LRS \
  --kind StorageV2

# Create storage container
az storage container create \
  --name tfstate \
  --account-name applibraryktftstate
```

---

### Step 4: Add Secrets to GitHub

Navigate to: **GitHub Repository → Settings → Secrets and variables → Actions**

Click **"New repository secret"** and add these secrets:

#### Azure Authentication
| Secret Name | Value | Example |
|------------|-------|---------|
| `AZURE_SUBSCRIPTION_ID` | From Step 1 output | `00000000-0000-0000-0000-000000000000` |
| `AZURE_TENANT_ID` | From Step 2 | `00000000-0000-0000-0000-000000000000` |
| `AZURE_CLIENT_ID` | `appId` from Step 1 | `00000000-0000-0000-0000-000000000000` |
| `AZURE_CLIENT_SECRET` | `password` from Step 1 | `super-secret-key...` |

#### Azure Resources
| Secret Name | Value | Example |
|------------|-------|---------|
| `AZURE_RESOURCE_GROUP` | Resource group name | `applibrarykit-prod-rg` |
| `AZURE_STORAGE_ACCOUNT` | Storage account name | `applibrarykit<random>` |
| `AZURE_APPSERVICE_NAME` | App Service name | `applibrarykit-prod-api` |

#### Terraform Backend (Optional but Recommended)
| Secret Name | Value | Example |
|------------|-------|---------|
| `TF_BACKEND_RG` | State resource group | `applibrarykit-prod-rg` |
| `TF_BACKEND_SA` | State storage account | `applibraryktftstate` |
| `TF_BACKEND_CONTAINER` | State container name | `tfstate` |
| `TF_BACKEND_KEY` | State file name | `applibrarykit.tfstate` |

#### Environment Variables (Optional)
| Secret Name | Value | Example |
|------------|-------|---------|
| `REACT_APP_API_BASE_URL` | API endpoint | `https://applibrarykit-prod-api.azurewebsites.net` |
| `SONAR_TOKEN` | SonarQube token | (if using SonarCloud) |
| `SLACK_WEBHOOK_URL` | Slack webhook | (if using Slack) |

---

## 🔑 Example: How to Add a Secret

### Via GitHub UI

1. Go to repository **Settings**
2. Click **"Secrets and variables"** → **"Actions"**
3. Click **"New repository secret"**
4. **Name**: `AZURE_SUBSCRIPTION_ID`
5. **Value**: Paste your subscription ID
6. Click **"Add secret"**

### Via GitHub CLI

```bash
# Install GitHub CLI: https://cli.github.com

# Login to GitHub
gh auth login

# Add secrets (replace with your values)
gh secret set AZURE_SUBSCRIPTION_ID --body "00000000-0000-0000-0000-000000000000"
gh secret set AZURE_TENANT_ID --body "00000000-0000-0000-0000-000000000000"
gh secret set AZURE_CLIENT_ID --body "00000000-0000-0000-0000-000000000000"
gh secret set AZURE_CLIENT_SECRET --body "super-secret-key..."
gh secret set AZURE_RESOURCE_GROUP --body "applibrarykit-prod-rg"
gh secret set AZURE_STORAGE_ACCOUNT --body "applibrarykit..."
gh secret set AZURE_APPSERVICE_NAME --body "applibrarykit-prod-api"

# Terraform backend (optional)
gh secret set TF_BACKEND_RG --body "applibrarykit-prod-rg"
gh secret set TF_BACKEND_SA --body "applibraryktftstate"
gh secret set TF_BACKEND_CONTAINER --body "tfstate"
gh secret set TF_BACKEND_KEY --body "applibrarykit.tfstate"
```

---

## 🔒 Security Best Practices

### Regenerate Service Principal Password
```bash
az ad sp credential reset \
  --name "github-actions-applibrarykit"
```

### Rotate Secrets Regularly
- Every 90 days for production
- After any security incident
- When team members change

### Limit RBAC Permissions
Instead of "Contributor", use:

```bash
# Create custom role with minimal permissions
az role assignment create \
  --assignee <app-id> \
  --role "Owner" \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/applibrarykit-prod-rg"
```

### Audit Secret Usage
```bash
# View recent deployments
gh run list --limit 10

# View logs
gh run view <run-id> --log
```

---

## ✅ Verification Checklist

After setup, verify everything is configured:

- [ ] All Azure secrets added to GitHub
- [ ] GitHub Actions workflow has access to secrets
- [ ] Azure service principal has correct RBAC role
- [ ] Terraform backend storage account created and accessible
- [ ] Resource group exists in Azure
- [ ] Terraform state is not committed to repository

---

## 🧪 Test Workflow

### Dry Run (Without Deploying)

1. Go to **Actions** tab
2. Select **"CI - Build & Quality"**
3. Click **"Run workflow"** on `main` branch
4. Review logs for errors

### Deploy Test

1. Go to **Actions** tab
2. Select **"Deploy to Azure"**
3. Click **"Run workflow"** (this is manual trigger)
4. Choose branch `main`
5. Click **"Run workflow"**
6. Monitor the workflow for errors

---

## 🐛 Troubleshooting

### Secret Not Found
**Error**: `Secret not found in environment variables`

**Solution**:
1. Verify secret name matches exactly (case-sensitive)
2. Workflow has access to the secret
3. Secret is not prefixed with `INPUT_`

### Authentication Failed
**Error**: `Error: Error acquiring the lock`

**Solution**:
```bash
# Verify service principal credentials
az login --service-principal \
  -u $AZURE_CLIENT_ID \
  -p $AZURE_CLIENT_SECRET \
  --tenant $AZURE_TENANT_ID
```

### Terraform State Lock
**Error**: `Error: Error acquiring the lock`

**Solution**:
```bash
# Check locks
az storage blob lease list \
  --account-name <storage-account> \
  --container-name tfstate

# Break lock if needed
az storage blob lease break \
  --account-name <storage-account> \
  --container-name tfstate \
  --blob-name applibrarykit.tfstate
```

---

## 📞 Support

For issues with GitHub secrets or Azure setup, contact:
- [GitHub Support](https://support.github.com)
- [Azure Support](https://azure.microsoft.com/support/)

---

**Last Updated**: November 2025
=======
This guide helps configure all required GitHub repository secrets for CI/CD workflows.

## 🔐 Required Secrets

### Azure Authentication
- AZURE_SUBSCRIPTION_ID
- AZURE_TENANT_ID
- AZURE_CLIENT_ID
- AZURE_CLIENT_SECRET

### Azure Resources
- AZURE_RESOURCE_GROUP
- AZURE_STORAGE_ACCOUNT
- AZURE_APPSERVICE_NAME

### Terraform Backend (Optional)
- TF_BACKEND_RG
- TF_BACKEND_SA
- TF_BACKEND_CONTAINER
- TF_BACKEND_KEY

See SECRETS_SETUP.md for detailed instructions.
>>>>>>> 4c1262cb642ac2382ff24bab4ccb57c432b68bd3
