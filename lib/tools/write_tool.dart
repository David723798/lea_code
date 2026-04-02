import 'dart:io';

import 'package:genkit/genkit.dart';
import 'package:lea_code/tools/runtime/tool_runtime.dart';
import 'package:lea_code/tools/utils/legacy_tool_support.dart';
import 'package:schemantic/schemantic.dart';

/// Builds the tool that writes files inside the workspace.
Tool<JsonMap, String> createWriteTool(
  Genkit ai, {
  required ToolRuntime runtime,
}) {
  const toolName = 'write';
  return ai.defineTool(
    name: toolName,
    description: 'Writes a file to disk inside the workspace.',
    inputSchema: createJsonObjectSchema(
      description: 'Input for the write tool.',
      properties: <String, $Schema>{
        'file_path': $Schema.string(
          description: 'Absolute path to the file to write.',
        ),
        'content': $Schema.string(
          description: 'The full content to write.',
        ),
      },
      required: <String>['file_path', 'content'],
    ),
    outputSchema: stringOutputSchema,
    fn: (input, _) async {
      final filePath = readString(input, 'file_path')?.trim();
      final content = readString(input, 'content');

      if (filePath == null || filePath.isEmpty) {
        const error = 'Error: `file_path` is required.';
        runtime.endTool(toolName, error);
        return error;
      }
      if (!_isAbsolutePath(filePath)) {
        const error = 'Error: `file_path` must be an absolute path.';
        runtime.endTool(toolName, error);
        return error;
      }
      if (!runtime.isWithinWorkspace(filePath)) {
        const error = 'Error: write operations must stay inside the workspace.';
        runtime.endTool(toolName, error);
        return error;
      }
      if (content == null) {
        const error = 'Error: `content` is required.';
        runtime.endTool(toolName, error);
        return error;
      }

      final file = File(filePath);
      final existed = await file.exists();
      if (existed) {
        final tracked = runtime.trackedFile(filePath);
        if (tracked == null) {
          const error = 'Error: existing files must be read before overwriting.';
          runtime.endTool(toolName, error);
          return error;
        }
        if (!await runtime.fileMatchesTrackedState(filePath)) {
          const error = 'Error: file has changed since it was last read. Read it again before overwriting.';
          runtime.endTool(toolName, error);
          return error;
        }
      }

      runtime.startTool(toolName, filePath);
      await file.parent.create(recursive: true);
      await file.writeAsString(content);
      final stat = await file.stat();
      runtime.recordFileRead(file.path, content, stat);

      final output = existed ? 'Overwrote $filePath.' : 'Created $filePath.';
      runtime.endTool(toolName, output);
      return output;
    },
  );
}

bool _isAbsolutePath(String path) {
  return path.startsWith('/') || RegExp(r'^[A-Za-z]:[\\/]').hasMatch(path);
}
