
// Install from the NuGet package manager or command line:
// dotnet add package OpenAI

using OpenAI;
using OpenAI.Chat;
using System.ClientModel;
using System.Net;

public class AzureOpenAIResponse
{
    private readonly string _endpoint;
    private readonly string _apiKey; 


    public AzureOpenAIResponse(string endpoint,string apiKey)
    {
        _endpoint = endpoint;
        _apiKey = apiKey;
    }

    public string getResponse(string prompt)
    {

        ChatClient client = new(
            credential: new ApiKeyCredential(_apiKey),
            model: "gpt-4o",
            options: new OpenAIClientOptions()
            {
                Endpoint = new($"{_endpoint}"),
            });

        ChatCompletion completion = client.CompleteChat(
             [
            //Examples of messages to set the behavior of the assistant
            // new SystemChatMessage("You are a helpful assistant that talks like a pirate."),
            // new UserChatMessage("Hi, can you help me?"),
             // new AssistantChatMessage("Arrr! Of course, me hearty! What can I do for ye?"),
              new UserChatMessage(prompt)
     ]);

       // Console.WriteLine($"Model={completion.Model}");
        string message = "";
        foreach (ChatMessageContentPart contentPart in completion.Content)
        {
            message = message + " " + contentPart.Text;
           // Console.WriteLine($"Chat Role: {completion.Role}");
           // Console.WriteLine("Message:");
          //  Console.WriteLine(message);
        }

        return message;
    }

}
