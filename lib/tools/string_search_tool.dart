import 'dart:io';

import 'package:genkit/genkit.dart';
import 'package:lea_code/models/string_search_input.dart';

/// Builds the tool that recursively searches files for matching text.
Tool<StringSearchInput, String> createStringSearchTool(Genkit ai) {
  return ai.defineTool(
    name: 'string_search',
    description: 'Searches for a string in the current directory.',
    inputSchema: StringSearchInput.$schema,
    outputSchema: .string(),
    fn: (input, _) async {
      final query = input.query;
      print('[string_search] $query');
      final result = await Process.run('grep', ['-r', query, '.']);
      print('[string_search] completed');
      return result.stdout;
    },
  );
}
