# Azure DevOps Service Connection Setup Guide

This guide walks you through setting up an Azure Service Connection in Azure DevOps for pipeline authentication and deployment.

## 📋 Prerequisites

- Azure subscription with Owner or Contributor role
- Azure DevOps organization admin access
- Azure CLI installed (optional but recommended)
- git installed

## 🔐 Step 1: Create Azure Service Principal

Service Principal allows Azure DevOps to authenticate with Azure without storing credentials in code.

### Option A: Using Azure CLI (Recommended)

```powershell
# Login to Azure
az login

# Set subscription
az account set --subscription "<YOUR_SUBSCRIPTION_ID>"

# Create Service Principal
$SP = az ad sp create-for-rbac `
  --name "applibrarykit-pipeline" `
  --role "Contributor" `
  --scopes "/subscriptions/<YOUR_SUBSCRIPTION_ID>"

# Display credentials (save these!)
$SP | ConvertFrom-Json
```

**Output includes:**
- `appId` → Client ID
- `password` → Client Secret  
- `tenant` → Tenant ID

### Option B: Using Azure Portal

1. Navigate to **Azure Portal** → **Azure Active Directory** → **App registrations**
2. Click **New registration**
   - Name: `applibrarykit-pipeline`
   - Supported account types: Single tenant
   - Click **Register**
3. Copy **Application (client) ID** and **Directory (tenant) ID**
4. Go to **Certificates & secrets**
   - Click **New client secret**
   - Description: `Azure DevOps Pipeline`
   - Expires: 24 months (or as per policy)
   - Click **Add**
   - **Copy the secret value immediately** (you won't see it again)
5. Grant permissions:
   - Go to **Subscriptions** → Your subscription
   - **Access control (IAM)** → **Add role assignment**
   - Role: `Contributor`
   - Members: Search for app name `applibrarykit-pipeline`
   - Click **Review + assign**

## 🔑 Step 2: Gather Required Credentials

From Service Principal creation, you need:

```
Subscription ID:    xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Tenant ID:          xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Service Principal ID (Client ID):  xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Service Principal Secret (Password): xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

**⚠️ Important:** Treat client secret like a password. Never commit to version control.

## 📋 Step 3: Create Service Connection in Azure DevOps

### Method 1: Automated Service Connection (Recommended)

1. In Azure DevOps, go to **Project Settings** → **Service connections**
2. Click **New service connection**
3. Select **Azure Resource Manager**
4. Select **Service principal (automatic)**
5. Azure portal will open:
   - Select your **Subscription**
   - Select **Resource group** (or leave empty for all)
   - **Service connection name:** `AzureServiceConnection`
   - Check **Grant access permission to all pipelines**
   - Click **Save**
6. Return to Azure DevOps - connection is created!

### Method 2: Manual Service Connection

1. In Azure DevOps, go to **Project Settings** → **Service connections**
2. Click **New service connection**
3. Select **Azure Resource Manager**
4. Select **Service principal (manual)**
5. Fill in credentials:
   - **Subscription ID:** xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   - **Subscription Name:** (your subscription name)
   - **Service principal ID:** xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx (Client ID)
   - **Service principal key:** xxxxx...xxxxx (Client Secret)
   - **Tenant ID:** xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   - **Service connection name:** `AzureServiceConnection`
   - Check **Grant access permission to all pipelines**
6. Click **Verify and save**

## ✅ Step 4: Verify Service Connection

### Test Connection

1. Go to **Project Settings** → **Service connections**
2. Find `AzureServiceConnection`
3. Click the three dots (...) → **Edit**
4. Click **Verify connection**
5. Should show ✅ if successful

<<<<<<< HEAD
### Test with Azure CLI

```powershell
# Using service principal credentials
$appId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
$password = "xxxxx...xxxxx"
$tenantId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

az login --service-principal -u $appId -p $password --tenant $tenantId

# List resources
az group list
```

=======
>>>>>>> 4c1262cb642ac2382ff24bab4ccb57c432b68bd3
## 📝 Step 5: Configure Pipeline Variables

In your Azure DevOps Pipeline, set these variables:

### Required Variables

Add in **Pipeline Settings** → **Variables**:

```
AzureServiceConnection     = AzureServiceConnection
EnvironmentName            = prod
ProjectName                = applibrarykit
<<<<<<< HEAD
AzureSubscriptionId        = xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
=======
>>>>>>> 4c1262cb642ac2382ff24bab4ccb57c432b68bd3
ResourceGroupName          = applibrarykit-prod-rg
StorageAccountName         = applibrarykit<unique>
AppServiceName             = applibrarykit-prod-api
ReactAppApiBaseUrl         = https://applibrarykit-prod-api.azurewebsites.net
```

<<<<<<< HEAD
### Backend State Variables (for Terraform Remote State)

```
TfBackendResourceGroup     = terraform-state
TfBackendStorageAccount    = tfstate<unique>
TfBackendContainer         = tfstate
TfBackendKey               = applibrarykit.tfstate
```

=======
>>>>>>> 4c1262cb642ac2382ff24bab4ccb57c432b68bd3
### Secret Variables 🔒

Mark these as **secrets** by clicking lock icon:

```
AzureClientSecret          = xxxxx...xxxxx (Service Principal Password)
AzureClientId              = xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
AzureTenantId              = xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

## 🛡️ Step 6: Security Best Practices

### Credential Rotation

1. **Every 12 months:**
   - Go to Azure Portal → App registrations
   - Select `applibrarykit-pipeline`
   - Go to **Certificates & secrets**
   - Delete old secret
   - Create new secret
   - Update service connection in Azure DevOps

<<<<<<< HEAD
2. **Use Key Rotation Policy (if available):**
   ```powershell
   # In Azure AD, set automatic rotation
   az ad app credential reset --id $appId --display-name "auto-rotated"
   ```

### Least Privilege Access

Instead of **Contributor** role on entire subscription, use custom role:

1. Go to **Subscriptions** → **Access control (IAM)**
2. Click **Add custom role**
3. Define role with only needed permissions:
   - `Microsoft.Resources/deployments/*`
   - `Microsoft.Storage/*`
   - `Microsoft.Web/*`
   - `Microsoft.KeyVault/*`
   - `Microsoft.Insights/*`

### Restrict Resource Groups

Instead of subscription-level access, limit to resource group:

```powershell
# Grant Contributor role on specific resource group only
az role assignment create `
  --assignee $appId `
  --role "Contributor" `
  --scope "/subscriptions/<SUB_ID>/resourceGroups/applibrarykit-prod-rg"
```

### Audit and Monitoring

1. Enable **Azure Activity Log** monitoring
2. Create alert for service principal sign-ins
3. Monitor Azure DevOps audit logs

```powershell
# View service principal activity
az monitor activity-log list --caller "<SERVICE_PRINCIPAL_ID>"
```

## 🔧 Step 7: Configure Terraform Backend (Optional)

For team collaboration, store Terraform state remotely:

### Create Terraform Backend Resources

```powershell
# Create resource group
az group create -n terraform-state -l eastus

# Create storage account for Terraform state
$storageAccount = "tfstate$(Get-Random -Maximum 999999)"
az storage account create `
  -n $storageAccount `
  -g terraform-state `
  -l eastus `
  --sku Standard_GRS

# Create container for Terraform state
az storage container create `
  -n tfstate `
  --account-name $storageAccount

# Save storage account name
Write-Host "Storage Account: $storageAccount"
```

### Grant Service Principal Access to Backend

```powershell
# Get storage account ID
$storageId = (az storage account show `
  -n $storageAccount `
  -g terraform-state `
  --query id -o tsv)

# Grant service principal Storage Blob Contributor role
az role assignment create `
  --assignee $appId `
  --role "Storage Blob Data Contributor" `
  --scope $storageId
```

### Configure Pipeline Variables

Add these variables in Azure DevOps:

```
TfBackendResourceGroup  = terraform-state
TfBackendStorageAccount = tfstate<YOUR_UNIQUE_NUMBER>
TfBackendContainer      = tfstate
TfBackendKey            = applibrarykit.tfstate
```

## 🧪 Step 8: Test the Connection

### Run Sample Pipeline

1. Go to **Pipelines** → Create new pipeline
2. Select repository
3. Choose `azure-pipelines-ci.yml`
4. Click **Save and run**
5. Monitor job logs for errors

### Manual Verification

```powershell
# Test with Azure DevOps CLI
az devops configure --defaults organization='https://dev.azure.com/<ORG_NAME>' project='<PROJECT_NAME>'

# List service connections
az devops service-endpoint list

# Check service connection details
az devops service-endpoint show --id '<SERVICE_CONNECTION_ID>'
```

## ❌ Troubleshooting

### Error: "Could not fetch access token"

**Solution:**
1. Verify service principal credentials are correct
2. Check service principal has Contributor role on subscription
3. Verify tenant ID is correct
4. Try removing and recreating service connection

### Error: "The object ID of user/app must be a valid GUID"

**Solution:**
1. Verify Client ID (Service Principal ID) format
2. Ensure you copied the entire ID
3. Check Service Principal exists: `az ad sp show --id <CLIENT_ID>`

### Error: "Insufficient privileges to complete the operation"

**Solution:**
1. Check role assignment: `az role assignment list --assignee <CLIENT_ID>`
2. Ensure role is "Contributor" (not Reader)
3. Grant role at correct scope (subscription or resource group)

### Error: "Request exceeded retry limits"

**Solution:**
1. Check internet connectivity
2. Verify Azure service availability
3. Increase timeout in pipeline (add `timeoutInMinutes: 60` to job)

### Pipeline Variables Not Recognized

**Solution:**
1. Ensure variables defined in Pipeline Settings, not in YAML
2. For secret variables, use: `$(VarName)`
3. Verify variable names match exactly (case-sensitive in some contexts)

## 📊 Service Connection Health Checks

Create a test job to verify connectivity:

```yaml
- job: VerifyServiceConnection
  displayName: 'Verify Azure Service Connection'
  pool:
    vmImage: 'ubuntu-latest'
  steps:
    - task: AzureCLI@2
      inputs:
        azureSubscription: '$(AzureServiceConnection)'
        scriptType: 'bash'
        scriptLocation: 'inlineScript'
        inlineScript: |
          echo "✓ Service Connection Verified!"
          echo "Subscription: $(az account show --query name -o tsv)"
          echo "Resource Groups:"
          az group list --query "[].name" -o tsv
```

## 🔄 Refresh Service Connection

If service connection fails after some time:

1. Go to **Project Settings** → **Service connections**
2. Click service connection name
3. Click **Edit** (pencil icon)
4. Reenter or verify credentials
5. Click **Verify and save**

## 📚 References

- [Azure DevOps Service Connections](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints)
- [Azure Service Principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals)
- [Azure RBAC Roles](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles)
- [Terraform Azure Backend](https://www.terraform.io/language/settings/backends/azurerm)

=======
>>>>>>> 4c1262cb642ac2382ff24bab4ccb57c432b68bd3
## ✅ Checklist

- [ ] Azure Service Principal created
- [ ] Service connection created in Azure DevOps
- [ ] Service connection verified
- [ ] Pipeline variables configured
- [ ] Secret variables marked as secure
<<<<<<< HEAD
- [ ] Terraform backend resources created (optional)
- [ ] Service principal granted appropriate roles
- [ ] Test pipeline executed successfully
- [ ] Azure activity logs show service principal usage
- [ ] Team members have access to pipelines
=======
- [ ] Test pipeline executed successfully
>>>>>>> 4c1262cb642ac2382ff24bab4ccb57c432b68bd3

---

**Next Steps:**
<<<<<<< HEAD
1. Configure pipeline variables as described in main [README.md](README.md)
2. Run test pipeline to verify connectivity
3. Deploy infrastructure with `azure-pipelines-deploy.yml`
4. Monitor deployments in Azure DevOps and Azure Portal
=======
1. Configure pipeline variables as described above
2. Run test pipeline to verify connectivity
3. Deploy infrastructure with `azure-pipelines-deploy.yml`
>>>>>>> 4c1262cb642ac2382ff24bab4ccb57c432b68bd3
