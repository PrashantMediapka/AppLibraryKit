using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

// Options class
public class AgenticAIOptions
{
    // Full base endpoint (e.g. https://your-resource.openai.azure.com/ or custom endpoint)
    public string? Endpoint { get; set; }

    // API key to send in request header
    public string? ApiKey { get; set; }

    // Header name to use for api key (default: "api-key")
    public string ApiKeyHeader { get; set; } = "api-key";
}

