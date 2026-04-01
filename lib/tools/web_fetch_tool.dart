import 'dart:io';

import 'package:genkit/genkit.dart';
import 'package:lea_code/models/web_fetch_input.dart';

/// Builds the tool that fetches the content of a URL.
Tool<WebFetchInput, String> createWebFetchTool(Genkit ai) {
  return ai.defineTool(
    name: 'web_fetch',
    description: 'Fetches the content of a URL.',
    inputSchema: WebFetchInput.$schema,
    outputSchema: .string(),
    fn: (input, _) async {
      final url = input.url;
      print('[web_fetch] $url');
      final result = await Process.run('curl', [
        '-s',
        'https://r.jina.ai/$url',
      ]);
      print('[web_fetch] completed');
      return result.stdout;
    },
  );
}
