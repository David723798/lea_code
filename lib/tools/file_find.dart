import 'dart:io';

import 'package:genkit/genkit.dart';
import 'package:lea_code/models/file_find_input.dart';

/// Builds the tool that finds files and directories by name.
Tool<FileFindInput, String> createFileFindTool(Genkit ai) {
  return ai.defineTool(
    name: 'file_find',
    description: 'Finds files and directories in the current directory.',
    inputSchema: FileFindInput.$schema,
    outputSchema: .string(),
    fn: (input, _) async {
      final query = input.query;
      print('[file_find] $query');
      final result = await Process.run('find', ['.', '-name', query]);
      print('[file_find] completed');
      return result.stdout;
    },
  );
}
