import 'dart:io';
import 'package:genkit/genkit.dart';
import 'package:lea_code/models/bash_input.dart';

/// Builds the tool that executes shell commands through `bash -c`.
Tool<BashInput, String> createBashTool(Genkit ai) {
  return ai.defineTool(
    name: 'bash',
    description: 'Executes a shell command and returns the output.',
    inputSchema: BashInput.$schema,
    outputSchema: .string(),
    fn: (input, _) async {
      final command = input.command;
      print('[bash] $command');
      final result = await Process.run('bash', ['-c', command]);
      print('[bash] completed');
      return '${result.stdout}${result.stderr}';
    },
  );
}
