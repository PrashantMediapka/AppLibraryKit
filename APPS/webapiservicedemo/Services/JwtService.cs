using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using WebApiDemo.Models;

namespace WebApiDemo.Services
{
    /// <summary>
    /// Service for generating and validating JWT tokens.
    /// </summary>
    public interface IJwtService
    {
        /// <summary>
        /// Generates a JWT token for the given username.
        /// </summary>
        string GenerateToken(UserInfo userinfo);
        /// <summary>
        /// Validates a JWT token and returns the principal if valid.
        /// </summary>
        ClaimsPrincipal? ValidateToken(string token);
    }

    /// <summary>
    /// JWT token service implementation.
    /// </summary>
    public class JwtService : IJwtService
    {
        private readonly string _secretKey;
        private readonly string _issuer;
        private readonly string _audience;
        private readonly int _expirationMinutes;

        public JwtService(IConfiguration configuration)
        {
            _secretKey = configuration["Jwt:SecretKey"] ?? throw new ArgumentNullException("Jwt:SecretKey not configured");
            _issuer = configuration["Jwt:Issuer"] ?? "WebApiDemo";
            _audience = configuration["Jwt:Audience"] ?? "WebAppClient";
            _expirationMinutes = int.Parse(configuration["Jwt:ExpirationMinutes"] ?? "60");
        }

        /// <summary>
        /// Generates a JWT token with standard claims (username, issued at, expiration).
        /// </summary>
        public string GenerateToken(UserInfo userinfo)
        {
            // Pseudocode / plan:
            // 1. Create a symmetric security key from the configured secret.
            // 2. Create signing credentials using HMAC-SHA256.
            // 3. Convert the user roles (string[]?) into a JSON array string, producing "[]" when roles are null/empty.
            //    - Use System.Text.Json.JsonSerializer.Serialize(...) with a fallback to Array.Empty<string>().
            // 4. Build claims array including NameIdentifier, Name, issuer claim, and a "roles" claim containing the JSON array string.
            // 5. Create JwtSecurityToken with issuer, audience, claims, expiration, and signing credentials.
            // 6. Return the serialized token string.
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_secretKey));
            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            // Serialize roles to a JSON array string like: ["Admin","Owner"]
            var rolesJson = System.Text.Json.JsonSerializer.Serialize(userinfo.Roles ?? Array.Empty<string>());

            var claims = new[]
            {
                new Claim(ClaimTypes.NameIdentifier, userinfo.UserId.ToString()),
                new Claim(ClaimTypes.Name, userinfo.Username),
                new Claim("iss", _issuer),
                new Claim("roles", rolesJson),
            };

            var token = new JwtSecurityToken(
                issuer: _issuer,
                audience: _audience,
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(_expirationMinutes),
                signingCredentials: credentials
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        /// <summary>
        /// Validates a JWT token and returns the claims principal if valid; otherwise null.
        /// </summary>
        public ClaimsPrincipal? ValidateToken(string token)
        {
            try
            {
                var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_secretKey));
                var tokenHandler = new JwtSecurityTokenHandler();

                var principal = tokenHandler.ValidateToken(token, new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = key,
                    ValidateIssuer = true,
                    ValidIssuer = _issuer,
                    ValidateAudience = true,
                    ValidAudience = _audience,
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.Zero,
                }, out SecurityToken validatedToken);

                return principal;
            }
            catch
            {
                return null;
            }
        }
    }
}
