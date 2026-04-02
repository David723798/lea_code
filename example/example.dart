void main() {
  print('''
lea usage:
-m, --model            The model to use
                       (defaults to "gemini-flash-lite-latest")
-p, --provider         The provider to use
                       [google (default), openai]
-b, --base_url         The base URL to use
-k, --api_key          The API key to use
-s, --system_prompt    The system prompt to use
-t, --max_turns        The maximum number of turns to allow in a conversation
                       (defaults to "100")
-v, --[no-]version     Show version
-h, --[no-]help        Show help
''');
}
