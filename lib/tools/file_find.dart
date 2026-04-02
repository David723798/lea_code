import 'dart:io';

import 'package:genkit/genkit.dart';
import 'package:lea_code/models/file_find_input.dart';
import 'package:lea_code/tools/models/tool_status.dart';

/// Builds the tool that finds files and directories by name.
Tool<FileFindInput, String> createFileFindTool(
  Genkit ai, {
  required void Function(ToolStatus) onMessage,
}) {
  const toolName = 'file_find';
  return ai.defineTool(
    name: toolName,
    description: 'Finds files and directories in the current directory.',
    inputSchema: FileFindInput.$schema,
    outputSchema: .string(),
    fn: (input, _) async {
      final query = input.query;
      onMessage(ToolStatusStart(name: toolName, message: query));
      final result = await Process.run('find', ['.', '-name', query]);
      final output = result.stdout;
      onMessage(ToolStatusEnd(name: toolName, message: output));
      return output;
    },
  );
}
