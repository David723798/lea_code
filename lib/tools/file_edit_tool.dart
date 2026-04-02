import 'dart:io';
import 'package:genkit/genkit.dart';
import 'package:lea_code/models/file_edit_input.dart';
import 'package:lea_code/tools/models/tool_status.dart';

/// Builds the tool that edits a file on disk.
Tool<FileEditInput, String> createFileEditTool(
  Genkit ai, {
  required void Function(ToolStatus) onMessage,
}) {
  const toolName = 'file_edit';
  return ai.defineTool(
    name: toolName,
    description: 'Edits a file on disk.',
    inputSchema: FileEditInput.$schema,
    outputSchema: .string(),
    fn: (input, _) async {
      final path = input.path;
      final sedCommand = input.sedCommand;
      onMessage(ToolStatusStart(name: toolName, message: '$sedCommand $path'));
      final result = await Process.run('sed', ['-i', '', sedCommand, path]);
      final output = '${result.stdout}${result.stderr}';
      onMessage(ToolStatusEnd(name: toolName, message: output));
      return output;
    },
  );
}
