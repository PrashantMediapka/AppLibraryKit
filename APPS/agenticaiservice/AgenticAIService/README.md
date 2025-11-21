# AgenticAIService

This is a minimal .NET 8 Web API that exposes a single controller endpoint to forward prompts to an external Agentic AI/OpenAI-style endpoint.

 
 - The controller supports two authorization patterns:
   - API-key header: set `AgenticAI:ApiKeyHeader` to the header name (default `api-key`) and `AgenticAI:ApiKey` to the key value.
   - Authorization Bearer: set `AgenticAI:ApiKeyHeader` to `Authorization` and `AgenticAI:ApiKey` to the token; the controller will send `Authorization: Bearer <token>`.
