import 'dart:io';
import 'package:genkit/genkit.dart';
import 'package:lea_code/models/file_read_input.dart';

/// Builds the tool that reads file contents from disk.
Tool<FileReadInput, String> createFileReadTool(Genkit ai) {
  return ai.defineTool(
    name: 'file_read',
    description: 'Reads the content of a file.',
    inputSchema: FileReadInput.$schema,
    outputSchema: .string(),
    fn: (input, _) async {
      final path = input.path;
      print('[file_read] $path');
      final file = File(path);
      if (await file.exists()) {
        final result = await file.readAsString();
        print('[file_read] completed');
        return result;
      } else {
        return 'Error: File not found at $path';
      }
    },
  );
}
