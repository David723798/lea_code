import 'dart:io';
import 'package:args/args.dart';
import 'package:genkit_google_genai/genkit_google_genai.dart';
import 'package:lea_code/lea_code.dart';

/// Runs the interactive Lea Code command-line interface.
void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'model',
      abbr: 'm',
      defaultsTo: 'gemini-flash-lite-latest',
      help: 'The Gemini model to use',
    )
    ..addOption(
      'system_prompt',
      abbr: 's',
      defaultsTo: '',
      help: 'The system prompt to use',
    )
    ..addOption(
      'max_turns',
      abbr: 't',
      defaultsTo: '100',
      help: 'The maximum number of turns to allow in a conversation',
    );

  final argResults = parser.parse(arguments);
  final modelName = argResults['model'] as String;
  final systemPrompt = argResults['system_prompt'] as String;
  final maxTurns = int.parse(argResults['max_turns'] as String);

  final apiKey = Platform.environment['GOOGLE_GENAI_API_KEY'] ?? Platform.environment['GEMINI_API_KEY'];
  if (apiKey == null) {
    print(
      'Error: GOOGLE_GENAI_API_KEY or GEMINI_API_KEY environment variable is not set.',
    );
    exit(1);
  }

  final leaCode = LeaCode(
    model: googleAI.gemini(modelName),
    plugin: googleAI(),
    systemPrompt: systemPrompt,
    maxTurns: maxTurns,
  );

  await leaCode.run();
}
