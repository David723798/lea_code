import 'dart:io';
import 'package:genkit/genkit.dart';
import 'package:lea_code/models/bash_input.dart';
import 'package:lea_code/tools/models/tool_status.dart';

/// Builds the tool that executes shell commands through `bash -c`.
Tool<BashInput, String> createBashTool(
  Genkit ai, {
  required void Function(ToolStatus) onMessage,
}) {
  const toolName = 'bash';
  return ai.defineTool(
    name: toolName,
    description: 'Executes a shell command and returns the output.',
    inputSchema: BashInput.$schema,
    outputSchema: .string(),
    fn: (input, _) async {
      final command = input.command;
      onMessage(ToolStatusStart(name: toolName, message: command));
      final result = await Process.run('bash', ['-c', command]);
      final output = '${result.stdout}${result.stderr}';
      onMessage(ToolStatusEnd(name: toolName, message: output));
      return output;
    },
  );
}
