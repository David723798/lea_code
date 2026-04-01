import 'dart:io';
import 'package:args/args.dart';
import 'package:genkit/genkit.dart';
import 'package:genkit_google_genai/genkit_google_genai.dart';
import 'package:lea_code/lea_code_engine.dart';

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
    );

  final argResults = parser.parse(arguments);
  final modelName = argResults['model'] as String;
  final systemPrompt = argResults['system_prompt'] as String;

  final apiKey =
      Platform.environment['GOOGLE_GENAI_API_KEY'] ??
      Platform.environment['GEMINI_API_KEY'];
  if (apiKey == null) {
    print(
      'Error: GOOGLE_GENAI_API_KEY or GEMINI_API_KEY environment variable is not set.',
    );
    exit(1);
  }

  print('--- Lea Code ---');
  print('Using model: $modelName');
  print('Type "/exit" or "/quit" to leave.');
  print('Type "/new" to clear history and start fresh.');

  final engine = LeaCodeEngine(modelName: modelName);
  List<Message>? history;

  while (true) {
    stdout.write('\n> ');
    final input = stdin.readLineSync();

    final trimmed = input?.trim();

    if (trimmed == null ||
        trimmed.toLowerCase() == '/exit' ||
        trimmed.toLowerCase() == '/quit') {
      break;
    }

    if (trimmed.isEmpty) {
      continue;
    }

    if (trimmed == '/new') {
      history = null;
      print('Started a new conversation.');
      continue;
    }

    try {
      print('Thinking...');
      final response = await engine.ai.generate(
        model: googleAI.gemini(modelName),
        prompt: trimmed,
        messages: history,
        outputInstructions: systemPrompt,
        tools: engine.tools,
      );

      history = response.messages;

      print(response.text);
    } catch (e) {
      print('\nError: $e');
    }
  }

  print('Goodbye!');
}
