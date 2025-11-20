Terraform CI/CD helper

This folder contains helper documentation for GitHub Actions that run Terraform in this repo.

Secrets required by the workflow

- AZURE_CREDENTIALS: JSON output from `az ad sp create-for-rbac --sdk-auth`. This is used by the `azure/login` action.
- AZURE_SUBSCRIPTION_ID: Your Azure subscription ID (e.g. `f1944295-c875-4042-bb02-84b71e64719b`).

Generate and store the secrets (PowerShell)

1. Login and set subscription:

```powershell
az login # authenticate as mediapka@gmail.com
az account set --subscription "f1944295-c875-4042-bb02-84b71e64719b"
```

2. Create service principal and save JSON (SDK auth format):

```powershell
$spJson = az ad sp create-for-rbac --name "github-action-applibrarykit" --role Contributor --scopes "/subscriptions/f1944295-c875-4042-bb02-84b71e64719b" --sdk-auth
$spJson | Out-File -FilePath .\azure_sp_sdk_auth.json -Encoding utf8
```

3. Upload to GitHub secrets (use GitHub CLI):

```powershell
gh secret set AZURE_CREDENTIALS --body (Get-Content -Raw .\azure_sp_sdk_auth.json)
gh secret set AZURE_SUBSCRIPTION_ID --body "f1944295-c875-4042-bb02-84b71e64719b"
```

Notes

- Do NOT commit the JSON to git. Remove the local file once the secret is set.
- For least-privilege, consider scoping the service principal to a resource group rather than the entire subscription.
- If the workflow fails on `terraform validate` complaining about `azurerm_static_site`, upgrade the `azurerm` provider or remove that resource block.
