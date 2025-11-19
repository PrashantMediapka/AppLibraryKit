# AppLibraryKit

Full-stack web application combining:
- **Frontend**: React 19 + TypeScript with React Router 7
- **Backend**: .NET 8 ASP.NET Core Web API with JWT authentication
- **Deployment**: Azure Static Website (Storage Account) + GitHub Actions CI/CD
- **Infrastructure**: Terraform for Azure resources

## Project Structure

```
AppLibraryKit/
├── reactwebappdemo/          # React frontend (Create React App)
│   ├── src/
│   │   ├── components/       # React components (Login, Home, Header)
│   │   ├── api/              # API service layer (axios, authServiceApi)
│   │   ├── App.tsx           # Main app with routing
│   │   └── index.tsx         # Entry point
│   ├── .github/workflows/    # GitHub Actions CI/CD
│   ├── deployment/           # Terraform config & service principal script
│   ├── package.json          # Dependencies
│   └── tsconfig.json         # TypeScript config
│
└── webapiservicedemo/        # .NET 8 Web API backend
    ├── Controllers/          # API endpoints
    ├── Models/               # Data models
    ├── Services/             # JwtService for token generation
    ├── Program.cs            # ASP.NET Core configuration
    ├── appsettings.json      # JWT and app settings
    └── WebApiDemo.csproj     # Project file
```

## Features

### Frontend (React)
- ✅ Login component with form validation
- ✅ JWT token storage in localStorage
- ✅ Protected Home route with token validation
- ✅ User info display (fullName, email, username)
- ✅ Header component with logout
- ✅ Axios-based API client with Bearer token support
- ✅ React Router for SPA routing

### Backend (.NET 8)
- ✅ JWT token generation (HS256) with configurable expiration
- ✅ Token validation with exp, issuer, audience checks
- ✅ CORS middleware for React frontend (localhost:3000, 3001)
- ✅ AuthController with ValidateUser endpoint
- ✅ Dummy user validation (username: `admin`, password: `password`)
- ✅ Swagger/OpenAPI documentation
- ✅ Structured logging

### Deployment & Infrastructure
- ✅ Terraform provisioning of Azure Storage Account with Static Website
- ✅ GitHub Actions workflow for React deployment to gh-pages
- ✅ GitHub Actions workflow for React deployment to Azure Storage
- ✅ PowerShell script to create Azure service principal with RBAC

## Getting Started

### Prerequisites
- Node.js 18+ (for React)
- .NET 8 SDK (for Web API)
- Azure CLI (for infrastructure)
- PowerShell 7+ (for service principal script)

### Local Development

#### 1. Start the .NET 8 Web API
```bash
cd webapiservicedemo
dotnet restore
dotnet run
```
API runs on `https://localhost:5001` or `http://localhost:5000`

#### 2. Start the React Frontend (in another terminal)
```bash
cd reactwebappdemo
npm install
npm start
```
App opens on `http://localhost:3000`

#### 3. Login with demo credentials
- **Username**: `admin`
- **Password**: `password`

You'll receive a JWT token and be redirected to the Home page.

### Configuration

#### JWT Settings (.NET)
Edit `webapiservicedemo/appsettings.json`:
```json
{
  "Jwt": {
    "SecretKey": "SuperSecureJwtKey1234567890123456789",
    "Issuer": "WebApiDemo",
    "Audience": "WebAppClient",
    "ExpirationMinutes": 60
  }
}
```
⚠️ **For production**: Use a strong random secret (32+ characters) and store it securely.

#### API Base URL (React)
Edit `reactwebappdemo/src/api/apiBase.ts` or set env var:
```bash
REACT_APP_API_BASE_URL=http://localhost:5000
```

### Azure Deployment

#### 1. Create Azure Resources with Terraform
```bash
cd reactwebappdemo/deployment
terraform init
terraform plan
terraform apply
```

#### 2. Create Service Principal for GitHub Actions
```powershell
cd reactwebappdemo/deployment
.\create_service_principal.ps1 -ResourceGroupName reactwebappdemo-rg -StorageAccountName <storage-account-name>
```
Copy the output values to GitHub repository secrets:
- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_STORAGE_ACCOUNT`
- `AZURE_RESOURCE_GROUP`

#### 3. Deploy via GitHub Actions
Push to `main` branch to trigger the workflow or manually run it.

## API Endpoints

### Authentication
- **POST** `/api/auth/ValidateUser`
  - Request: `{ "username": "admin", "password": "password" }`
  - Response: `{ "isValid": true, "token": "eyJ...", "user": {...} }`

## Technology Stack

| Layer | Technology |
|-------|------------|
| Frontend | React 19, TypeScript 4.9, React Router 7.9, Axios 1.13 |
| Backend | .NET 8, ASP.NET Core, JWT Bearer Auth, Swagger/OpenAPI |
| Database | *Placeholder* (ready for EF Core + SQL Server/PostgreSQL) |
| Cloud | Azure Storage Account, Azure Static Website, Azure RBAC |
| IaC | Terraform 1.0+ |
| CI/CD | GitHub Actions |

## Development Roadmap

- [ ] Implement token refresh logic
- [ ] Add role-based access control (RBAC)
- [ ] Integrate Entity Framework Core with SQL Server
- [ ] Employee/user management endpoints
- [ ] Protected API endpoints with [Authorize] attribute
- [ ] Unit and integration tests
- [ ] Docker containerization

## Contributing

Fork this repository, create a feature branch, and submit a pull request.

## License

MIT

## Support

For issues or questions, open a GitHub issue in this repository.
