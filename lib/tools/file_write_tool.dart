import 'dart:io';
import 'package:genkit/genkit.dart';
import 'package:lea_code/models/file_write_input.dart';
import 'package:lea_code/tools/models/tool_status.dart';

/// Builds the tool that writes content to a file on disk.
Tool<FileWriteInput, String> createFileWriteTool(
  Genkit ai, {
  required void Function(ToolStatus) onMessage,
}) {
  const toolName = 'file_write';
  return ai.defineTool(
    name: toolName,
    description: 'Writes content to a file.',
    inputSchema: FileWriteInput.$schema,
    outputSchema: .string(),
    fn: (input, _) async {
      final path = input.path;
      final content = input.content;
      onMessage(ToolStatusStart(name: toolName, message: path));
      final file = File(path);
      await file.writeAsString(content);
      final output = 'Successfully wrote to $path';
      onMessage(ToolStatusEnd(name: toolName, message: output));
      return output;
    },
  );
}
