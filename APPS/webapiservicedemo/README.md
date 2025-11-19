# WebApiDemo - .NET 8 Web API

ASP.NET Core 8 Web API for user authentication with Swagger/OpenAPI support.

## Quick Start

### Prerequisites
- .NET 8 SDK installed (https://dotnet.microsoft.com/en-us/download/dotnet/8.0)

### Build
```bash
dotnet build
```

### Run
```bash
dotnet run
```

The API will start on `https://localhost:5001` (or HTTP on `http://localhost:5000` for development).

### Swagger UI
Open http://localhost:5000/swagger in your browser to explore the API endpoints.

## API Endpoints

### POST /api/auth/ValidateUser
Validates user credentials.

**Request:**
```json
{
  "username": "admin",
  "password": "password"
}
```

**Response (Success):**
```json
{
  "isValid": true,
  "message": "Login successful.",
  "token": "token-admin-...",
  "user": {
    "username": "admin",
    "email": "admin@example.com",
    "fullName": "Administrator"
  }
}
```

**Response (Failure):**
```json
{
  "isValid": false,
  "message": "Invalid username or password."
}
```

## Testing with React Frontend

The React app at `../reactwebappdemo/src/api/authServiceApi.ts` calls this endpoint.

Ensure:
1. This API runs on a local port (default: 5000 or 5001).
2. CORS is configured in `Program.cs` to allow requests from React (http://localhost:3000).
3. React's axios baseURL points to http://localhost:5000 (or your API URL).

## Dummy Credentials
- Username: `admin`
- Password: `password`

Replace with real authentication (e.g., ASP.NET Core Identity, JWT) in production.

## Project Structure
```
webapiservicedemo/
├── Controllers/
│   └── AuthController.cs         # Authentication endpoint
├── Models/
│   └── LoginModels.cs            # Request/response models
├── Program.cs                    # Startup and configuration
├── appsettings.json              # Production settings
├── appsettings.Development.json  # Development settings
└── WebApiDemo.csproj             # Project file
```

## Next Steps
- Integrate with a real database for user storage.
- Implement JWT token generation and validation.
- Add user registration, refresh token, logout endpoints.
- Move from dummy credentials to ASP.NET Core Identity or similar.
