# Azure DevOps Pipeline - 5-Minute Quick Start

Get your Azure DevOps pipelines running in 5 minutes!

## ⚡ Quick Start (5 mins)

### 1. Create Service Principal (2 mins)

```powershell
# Login to Azure
az login

# Create service principal
az ad sp create-for-rbac `
  --name "applibrarykit-pipeline" `
  --role "Contributor" `
  --scopes "/subscriptions/<YOUR_SUBSCRIPTION_ID>"
```

**Save the output:**
- `appId` = Client ID
- `password` = Client Secret
- `tenant` = Tenant ID

### 2. Create Service Connection (1 min)

1. Azure DevOps → **Project Settings** → **Service connections**
2. **New service connection** → **Azure Resource Manager** → **Service principal (manual)**
3. Fill in credentials from Step 1
4. **Service connection name:** `AzureServiceConnection`
5. Click **Save**

### 3. Configure Pipeline (2 mins)

1. Go to **Pipelines** → **New pipeline**
2. Select your repository
3. Choose **Existing Azure Pipelines YAML**
4. Select `azure-pipelines-ci.yml`
5. Add variables (click **Variables** button):

```
AzureServiceConnection = AzureServiceConnection
EnvironmentName = prod
ProjectName = applibrarykit
<<<<<<< HEAD
ResourceGroupName = applibrarykit-prod-rg
=======
>>>>>>> 4c1262cb642ac2382ff24bab4ccb57c432b68bd3
AppServiceName = applibrarykit-prod-api
StorageAccountName = applibrarykit<unique>
```

6. Click **Save and run**

---

## ✅ Done! 🎉

Your pipeline is running!

## 📊 What Happens Next

**CI Pipeline:**
- ✅ Builds React app
- ✅ Builds .NET API
- ✅ Runs code quality checks
<<<<<<< HEAD
- ✅ Validates infrastructure
=======
>>>>>>> 4c1262cb642ac2382ff24bab4ccb57c432b68bd3

**Deployment Pipeline (optional):**
- 🏗️ Creates Azure resources (Terraform)
- 📦 Deploys React app to Storage
- 🚀 Deploys API to App Service

## 🔍 Monitor Pipeline

1. Go to **Pipelines** → **Recent**
2. Click on pipeline run
3. View logs in real-time

<<<<<<< HEAD
## 🛠️ Troubleshooting

**Pipeline failed?** Check logs:
1. Click pipeline run
2. Click failed stage
3. Click failed job
4. Scroll to see error message

**Common issues:**
- ❌ "Could not fetch access token" → Verify service principal credentials
- ❌ "Insufficient privileges" → Grant service principal Contributor role
- ❌ "Resource not found" → Check resource names in variables

See [README.md](README.md) for detailed troubleshooting.

## 📚 Next Steps

- Configure Terraform backend (see [SERVICE_CONNECTION_SETUP.md](SERVICE_CONNECTION_SETUP.md))
- Add SonarQube for code analysis
- Set up monitoring and alerts
- Configure branch policies

---

**Full Setup Guide:** [README.md](README.md)  
**Service Connection Details:** [SERVICE_CONNECTION_SETUP.md](SERVICE_CONNECTION_SETUP.md)
=======
---

**Full Setup Guide:** [SERVICE_CONNECTION_SETUP.md](SERVICE_CONNECTION_SETUP.md)
>>>>>>> 4c1262cb642ac2382ff24bab4ccb57c432b68bd3
