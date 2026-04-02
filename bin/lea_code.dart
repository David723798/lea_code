import 'package:args/args.dart';
import 'package:genkit_google_genai/genkit_google_genai.dart';
import 'package:genkit_openai/genkit_openai.dart';
import 'package:lea_code/lea_code.dart';

/// Runs the interactive Lea Code command-line interface.
void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'model',
      abbr: 'm',
      defaultsTo: 'gemini-flash-lite-latest',
      help: 'The model to use',
    )
    ..addOption(
      'provider',
      abbr: 'p',
      defaultsTo: 'google',
      allowed: ['google', 'openai'],
      help: 'The provider to use',
    )
    ..addOption(
      'base_url',
      abbr: 'b',
      help: 'The base URL to use',
    )
    ..addOption(
      'api_key',
      abbr: 'k',
      help: 'The API key to use',
    )
    ..addOption(
      'system_prompt',
      abbr: 's',
      help: 'The system prompt to use',
    )
    ..addOption(
      'max_turns',
      abbr: 't',
      defaultsTo: '100',
      help: 'The maximum number of turns to allow in a conversation',
    )
    ..addFlag(
      'version',
      abbr: 'v',
      help: 'Show version',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Show help',
    );

  final argResults = parser.parse(arguments);

  if (argResults['help'] as bool) {
    print('Usage:');
    print(parser.usage);
    return;
  }

  if (argResults['version'] as bool) {
    print('lea 0.0.7');
    return;
  }

  final modelName = argResults['model'] as String;
  final provider = argResults['provider'] as String;
  final baseUrl = argResults['base_url'] as String?;
  final apiKey = argResults['api_key'] as String?;
  final systemPrompt = argResults['system_prompt'] as String?;
  final maxTurns = int.parse(argResults['max_turns'] as String);

  final model = switch (provider.toLowerCase()) {
    'google' => googleAI.gemini(modelName),
    'openai' => openAI.model(modelName),
    _ => throw ArgumentError('Invalid provider: $provider'),
  };

  final plugin = switch (provider.toLowerCase()) {
    'google' => googleAI(
      apiKey: apiKey,
    ),
    'openai' => openAI(
      baseUrl: baseUrl,
      apiKey: apiKey,
    ),
    _ => throw ArgumentError('Invalid provider: $provider'),
  };

  final leaCode = LeaCode(
    model: model,
    plugin: plugin,
    systemPrompt: systemPrompt,
    maxTurns: maxTurns,
  );

  await leaCode.run();
}
