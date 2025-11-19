namespace WebApiDemo.Models
{
    /// <summary>
    /// Request model for user validation/login.
    /// </summary>
    public class LoginRequest
    {
        public string? Username { get; set; }
        public string? Password { get; set; }
    }

    /// <summary>
    /// Response model for validation result.
    /// </summary>
    public class LoginResponse
    {
        public bool IsValid { get; set; }
        public string? Message { get; set; }
        public string? Token { get; set; }
        public UserInfo? User { get; set; }
    }

    /// <summary>
    /// User information returned on successful validation.
    /// </summary>
    public class UserInfo
    {
        public int? UserId { get; set; }
        public string? Username { get; set; }
        public string? Email { get; set; }
        public string? FullName { get; set; }
        //added user roles 
        public string[]? Roles { get; set; }
    }
}
