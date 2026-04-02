import 'dart:io';
import 'package:genkit/genkit.dart';
import 'package:lea_code/models/file_read_input.dart';
import 'package:lea_code/tools/models/tool_status.dart';

/// Builds the tool that reads file contents from disk.
Tool<FileReadInput, String> createFileReadTool(
  Genkit ai, {
  required void Function(ToolStatus) onMessage,
}) {
  const toolName = 'file_read';
  return ai.defineTool(
    name: toolName,
    description: 'Reads the content of a file.',
    inputSchema: FileReadInput.$schema,
    outputSchema: .string(),
    fn: (input, _) async {
      final path = input.path;
      onMessage(ToolStatusStart(name: toolName, message: path));
      final file = File(path);
      if (await file.exists()) {
        final result = await file.readAsString();
        onMessage(ToolStatusEnd(name: toolName, message: result));
        return result;
      } else {
        final errorMessage = 'Error: File not found at $path';
        onMessage(ToolStatusEnd(name: toolName, message: errorMessage));
        return errorMessage;
      }
    },
  );
}
