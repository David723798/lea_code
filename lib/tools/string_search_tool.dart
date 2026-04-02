import 'dart:io';

import 'package:genkit/genkit.dart';
import 'package:lea_code/models/string_search_input.dart';
import 'package:lea_code/tools/models/tool_status.dart';

/// Builds the tool that recursively searches files for matching text.
Tool<StringSearchInput, String> createStringSearchTool(
  Genkit ai, {
  required void Function(ToolStatus) onMessage,
}) {
  const toolName = 'string_search';
  return ai.defineTool(
    name: toolName,
    description: 'Searches for a string in the current directory.',
    inputSchema: StringSearchInput.$schema,
    outputSchema: .string(),
    fn: (input, _) async {
      final query = input.query;
      onMessage(ToolStatusStart(name: toolName, message: query));
      final result = await Process.run('grep', ['-r', query, '.']);
      final output = result.stdout;
      onMessage(ToolStatusEnd(name: toolName, message: output));
      return output;
    },
  );
}
