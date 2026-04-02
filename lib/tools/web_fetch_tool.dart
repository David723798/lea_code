import 'dart:io';

import 'package:genkit/genkit.dart';
import 'package:lea_code/models/web_fetch_input.dart';
import 'package:lea_code/tools/models/tool_status.dart';

/// Builds the tool that fetches the content of a URL.
Tool<WebFetchInput, String> createWebFetchTool(
  Genkit ai, {
  required void Function(ToolStatus) onMessage,
}) {
  const toolName = 'web_fetch';
  return ai.defineTool(
    name: toolName,
    description: 'Fetches the content of a URL.',
    inputSchema: WebFetchInput.$schema,
    outputSchema: .string(),
    fn: (input, _) async {
      final url = input.url;
      onMessage(ToolStatusStart(name: toolName, message: url));
      final result = await Process.run('curl', [
        '-s',
        'https://r.jina.ai/$url',
      ]);
      final output = result.stdout;
      onMessage(ToolStatusEnd(name: toolName, message: output));
      return output;
    },
  );
}
