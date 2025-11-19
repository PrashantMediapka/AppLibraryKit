<<<<<<< HEAD
# GitHub Workflows - Quick Start Guide

Fast-track setup for GitHub CI/CD deployment of AppLibraryKit to Azure.

---

## 🚀 5-Minute Setup

### 1. Prepare Azure Service Principal (2 min)

```bash
# Get IDs
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)

# Create service principal
SP_JSON=$(az ad sp create-for-rbac \
  --name "github-actions-applibrarykit" \
  --role "Contributor" \
  --scopes "/subscriptions/$SUBSCRIPTION_ID" \
  --output json)

echo "$SP_JSON" | jq '{
  AZURE_CLIENT_ID: .appId,
  AZURE_CLIENT_SECRET: .password,
  AZURE_TENANT_ID: .tenant
}'
```

### 2. Add GitHub Secrets (2 min)

```bash
# Using GitHub CLI (install: https://cli.github.com)
gh secret set AZURE_SUBSCRIPTION_ID --body "$SUBSCRIPTION_ID"
gh secret set AZURE_TENANT_ID --body "$TENANT_ID"
gh secret set AZURE_CLIENT_ID --body "<appId from above>"
gh secret set AZURE_CLIENT_SECRET --body "<password from above>"
=======
# Quick Start Guide

## 5-Minute Setup

### 1. Create Azure Service Principal
```bash
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
az ad sp create-for-rbac \
  --name "github-actions-applibrarykit" \
  --role "Contributor" \
  --scopes "/subscriptions/$SUBSCRIPTION_ID" \
  --output json
```

### 2. Add GitHub Secrets
```bash
gh secret set AZURE_SUBSCRIPTION_ID --body "<value>"
gh secret set AZURE_TENANT_ID --body "<value>"
gh secret set AZURE_CLIENT_ID --body "<value>"
gh secret set AZURE_CLIENT_SECRET --body "<value>"
>>>>>>> 4c1262cb642ac2382ff24bab4ccb57c432b68bd3
gh secret set AZURE_RESOURCE_GROUP --body "applibrarykit-prod-rg"
gh secret set AZURE_STORAGE_ACCOUNT --body "applibrarykit<suffix>"
gh secret set AZURE_APPSERVICE_NAME --body "applibrarykit-prod-api"
```

<<<<<<< HEAD
### 3. Deploy (1 min)

```bash
# Option A: Automatic (push to main)
git push origin main

# Option B: Manual
# Go to Actions → Deploy to Azure → Run workflow
```

---

## 📁 What's Included

```
DEPLOYMENT/GITHUBWORKFLOWS/
├── ci-build-quality.yml           # Build & quality checks (every push)
├── deploy-azure.yml               # Deploy to Azure (main branch)
├── terraform/
│   ├── main.tf                    # Infrastructure provisioning
│   ├── variables.tf               # Variable definitions
│   ├── outputs.tf                 # Deployment outputs
│   └── terraform.tfvars.example   # Example values
├── README.md                      # Full documentation
├── SECRETS_SETUP.md              # Detailed secret configuration
└── QUICKSTART.md                 # This file
```

---

## 🔧 Minimal Setup (If You Have Azure Resources)

If resources already exist in Azure:

1. **Skip Terraform** - Edit `deploy-azure.yml` and comment out `terraform-deploy` job
2. **Add secrets** - Only Azure resource names needed
3. **Push** - Deployment workflows will use existing resources

---

## 📊 Available Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| **CI Build & Quality** | Every push/PR | Build, test, quality checks |
| **Deploy to Azure** | Manual or push to main | Build, deploy, infrastructure |

---

## 🎯 Typical Workflow

```
1. Developer pushes to main
   ↓
2. GitHub Actions triggers CI workflow
   ├─ Build React (npm build)
   ├─ Build .NET (dotnet publish)
   ├─ Quality checks (lint, test)
   └─ All pass? → Continue
   ↓
3. Deploy workflow automatically triggers
   ├─ Terraform provisions infrastructure
   ├─ Deploy React to Storage Account
   ├─ Deploy .NET to App Service
   └─ Health checks
   ↓
4. Deployments complete ✅
```

---

## 📍 Status & Monitoring

### View Workflow Status
```bash
# GitHub CLI
gh run list
gh run view <run-id>

# Or visit: GitHub repo → Actions tab
```

### Troubleshoot Failures
1. Click failed workflow
2. Expand job logs
3. Search for error message
4. Check resource names in secrets

---

## 🔑 Required Secrets

```
AZURE_SUBSCRIPTION_ID        # From: az account show --query id
AZURE_TENANT_ID              # From: az account show --query tenantId
AZURE_CLIENT_ID              # From: SP creation output (appId)
AZURE_CLIENT_SECRET          # From: SP creation output (password)
AZURE_RESOURCE_GROUP         # e.g., applibrarykit-prod-rg
AZURE_STORAGE_ACCOUNT        # Storage account for React
AZURE_APPSERVICE_NAME        # App Service for .NET API
```

**Optional (Terraform Backend)**
```
TF_BACKEND_RG
TF_BACKEND_SA
TF_BACKEND_CONTAINER
TF_BACKEND_KEY
```

---

## 💡 Tips

### Generate Storage Account Name
```bash
# Avoid special characters, use alphanumeric only
STORAGE_NAME="applibrarykit$(date +%s | tail -c 4)"
echo $STORAGE_NAME
```

### Get Existing Resource Names
```bash
# List all resources in subscription
az resource list --query "[].name" -o tsv
```

### Manual Testing
```bash
# Test locally before pushing
cd APPS/reactwebappdemo && npm run build
cd APPS/webapiservicedemo && dotnet publish -c Release
```

---

## ❌ Common Issues & Fixes

### "Secret not found"
- Check secret name matches exactly (case-sensitive)
- Verify it's in correct repository (not organization)

### "Terraform validate failed"
- Main.tf has syntax errors
- Run locally: `terraform validate`

### "Authentication failed to Azure"
- Service principal credentials incorrect
- Verify: `az login --service-principal -u $CLIENT_ID -p $CLIENT_SECRET --tenant $TENANT_ID`

### "App Service deployment timeout"
- Check App Service tier (B1 is minimum recommended)
- Verify network connectivity

---

## 🎓 Learn More

📚 [Full Documentation](README.md)
📚 [Secrets Setup Guide](SECRETS_SETUP.md)
📚 [Terraform Docs](https://www.terraform.io/docs)

---

## ✅ Checklist

Before first deployment:

- [ ] Service principal created
- [ ] All secrets added to GitHub
- [ ] Secrets set to PRIVATE (not public)
- [ ] Repository has Actions enabled
- [ ] Azure subscription is active
- [ ] Terraform version >= 1.0

---

**Ready?** Push to main and watch it deploy! 🚀

=======
### 3. Deploy
```bash
git push origin main
```

Workflows will automatically trigger! See README.md for full documentation.
>>>>>>> 4c1262cb642ac2382ff24bab4ccb57c432b68bd3
