import 'dart:io';
import 'package:genkit/genkit.dart';
import 'package:lea_code/models/file_write_input.dart';

/// Builds the tool that writes content to a file on disk.
Tool<FileWriteInput, String> createFileWriteTool(Genkit ai) {
  return ai.defineTool(
    name: 'file_write',
    description: 'Writes content to a file.',
    inputSchema: FileWriteInput.$schema,
    outputSchema: .string(),
    fn: (input, _) async {
      final path = input.path;
      final content = input.content;
      print('[file_write] $path');
      final file = File(path);
      await file.writeAsString(content);
      print('[file_write] completed');
      return 'Successfully wrote to $path';
    },
  );
}
