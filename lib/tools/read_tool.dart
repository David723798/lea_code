import 'dart:io';

import 'package:genkit/genkit.dart';
import 'package:lea_code/tools/runtime/tool_runtime.dart';
import 'package:lea_code/tools/utils/legacy_tool_support.dart';
import 'package:schemantic/schemantic.dart';

/// Builds the tool that reads text files from disk.
Tool<JsonMap, String> createReadTool(
  Genkit ai, {
  required ToolRuntime runtime,
}) {
  const toolName = 'read';
  return ai.defineTool(
    name: toolName,
    description: 'Reads a text file from an absolute path.',
    inputSchema: createJsonObjectSchema(
      description: 'Input for the read tool.',
      properties: <String, $Schema>{
        'file_path': $Schema.string(
          description: 'Absolute path to the file to read.',
        ),
        'offset': $Schema.integer(
          description: 'Optional 1-based starting line number.',
        ),
        'limit': $Schema.integer(
          description: 'Optional maximum number of lines to return.',
        ),
      },
      required: <String>['file_path'],
    ),
    outputSchema: stringOutputSchema,
    fn: (input, _) async {
      final filePath = readString(input, 'file_path')?.trim();
      final offset = readInt(input, 'offset') ?? 1;
      final limit = readInt(input, 'limit');

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

      final file = File(filePath);
      if (!await file.exists()) {
        final error = 'Error: file not found at $filePath.';
        runtime.endTool(toolName, error);
        return error;
      }

      runtime.startTool(toolName, filePath);
      final content = await file.readAsString();
      final stat = await file.stat();
      runtime.recordFileRead(file.path, content, stat);

      final numbered = _formatNumberedLines(
        content: content,
        offset: offset < 1 ? 1 : offset,
        limit: limit,
      );
      runtime.endTool(toolName, numbered);
      return numbered;
    },
  );
}

String _formatNumberedLines({
  required String content,
  required int offset,
  required int? limit,
}) {
  final lines = content.split('\n');
  if (lines.isEmpty) {
    return '';
  }

  final startIndex = offset - 1;
  if (startIndex >= lines.length) {
    return '';
  }

  final endExclusive = limit == null || limit < 1 ? lines.length : (startIndex + limit).clamp(0, lines.length);
  final width = '$endExclusive'.length;

  final selected = <String>[];
  for (var index = startIndex; index < endExclusive; index++) {
    final lineNumber = '${index + 1}'.padLeft(width);
    selected.add('$lineNumber\t${lines[index]}');
  }
  return selected.join('\n');
}

bool _isAbsolutePath(String path) {
  return path.startsWith('/') || RegExp(r'^[A-Za-z]:[\\/]').hasMatch(path);
}
