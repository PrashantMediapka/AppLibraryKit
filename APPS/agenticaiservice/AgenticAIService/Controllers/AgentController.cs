using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using AgenticAIService.Models;
namespace AgenticAIService.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AgentController : ControllerBase
{
    private readonly IHttpClientFactory _httpFactory;
    private readonly AgenticAIOptions _options;

  
    public AgentController(IHttpClientFactory httpFactory, IOptions<AgenticAIOptions> options)
    {
        _httpFactory = httpFactory;
        _options = options.Value;
    }

    [HttpGet("getAzOpenAIResponse")]
    public Task<IActionResult> GetAzOpenAIResponse([FromQuery] string prompt)
    {

        // NOTE - Responses will vary as per the model and context loaded 
        // to allow only loaded data source responses . 
        // In Azure AI project --> test in Chat playground --> load data and give proper text in the "Give the model instructions and context" section

        try
        {
            var azureOpenAIResponse = new AzureOpenAIResponse(_options.Endpoint, _options.ApiKey);
            string content = azureOpenAIResponse.getResponse(prompt);

            // Return raw upstream JSON
            return Task.FromResult<IActionResult>(Ok(content));
        }
        catch (Exception ex)
        {
            return Task.FromResult<IActionResult>(StatusCode(500, new { error = "internal_error", details = ex.Message }));
        }
    }

    #region This is todo - Experimetal Code

    // GET api/agent/getResponse?prompt=hello
    [HttpGet("getResponse")]
    public Task<IActionResult> GetResponse([FromQuery] string prompt)
        => HandleRequestAsync(new PromptRequest { Prompt = prompt, MaxTokens = 512 });

    // POST api/agent/getResponse
    [HttpPost("getResponse")]
    public Task<IActionResult> PostResponse([FromBody] PromptRequest request)
        => HandleRequestAsync(request);

    private async Task<IActionResult> HandleRequestAsync(PromptRequest request)
    {
        if (request == null || string.IsNullOrWhiteSpace(request.Prompt))
        {
            return BadRequest(new { error = "prompt is required" });
        }

        var client = _httpFactory.CreateClient("AgenticAI");

        // Authorization handling: support Authorization: Bearer and custom API-key header
        if (!string.IsNullOrWhiteSpace(_options.ApiKey))
        {
            if (string.Equals(_options.ApiKeyHeader, "Authorization", StringComparison.OrdinalIgnoreCase))
            {
                // Use Bearer scheme
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", _options.ApiKey);
            }
            else
            {
                if (!client.DefaultRequestHeaders.Contains(_options.ApiKeyHeader))
                {
                    client.DefaultRequestHeaders.Add(_options.ApiKeyHeader, _options.ApiKey);
                }
            }
        }

        // Build request payload - adapt to upstream API schema as needed
        var payload = new
        {
            prompt = request.Prompt,
            max_tokens = request.MaxTokens ?? 512
        };

        try
        {
            using var response = await client.PostAsJsonAsync(_options.Endpoint, payload); //"/openai/deployments/agentic/completions"
            var content = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
            {
                return StatusCode((int)response.StatusCode, new { error = "AgenticAI call failed", details = content });
            }

            // Return raw upstream JSON
            return Content(content, "application/json");
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { error = "internal_error", details = ex.Message });
        }
    }

    #endregion
}
