import 'dart:io';

import 'package:genkit/genkit.dart';
import 'package:lea_code/tools/runtime/tool_runtime.dart';
import 'package:lea_code/tools/utils/legacy_tool_support.dart';

/// Builds the tool that edits an existing file via exact string replacements.
Tool<JsonMap, String> createEditTool(
  Genkit ai, {
  required ToolRuntime runtime,
}) {
  const toolName = 'edit';
  return ai.defineTool(
    name: toolName,
    description: 'Edits an existing file using exact string replacements.',
    inputSchema: createJsonSchema(
      <String, dynamic>{
        'type': 'object',
        'description': 'Input for the edit tool.',
        'properties': <String, dynamic>{
          'file_path': <String, dynamic>{'type': 'string'},
          'edits': <String, dynamic>{
            'type': 'array',
            'items': <String, dynamic>{
              'type': 'object',
              'properties': <String, dynamic>{
                'old_text': <String, dynamic>{'type': 'string'},
                'new_text': <String, dynamic>{'type': 'string'},
                'replace_all': <String, dynamic>{'type': 'boolean'},
              },
              'required': <String>['old_text', 'new_text'],
              'additionalProperties': false,
            },
          },
        },
        'required': <String>['file_path', 'edits'],
        'additionalProperties': false,
      },
    ),
    outputSchema: stringOutputSchema,
    fn: (input, _) async {
      final filePath = readString(input, 'file_path')?.trim();
      final editsInput = readList(input, 'edits');

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
        const error = 'Error: edit operations must stay inside the workspace.';
        runtime.endTool(toolName, error);
        return error;
      }
      if (editsInput == null || editsInput.isEmpty) {
        const error = 'Error: `edits` must contain at least one edit.';
        runtime.endTool(toolName, error);
        return error;
      }

      final tracked = runtime.trackedFile(filePath);
      if (tracked == null) {
        const error = 'Error: file must be read with the read tool before editing.';
        runtime.endTool(toolName, error);
        return error;
      }
      if (!await runtime.fileMatchesTrackedState(filePath)) {
        const error = 'Error: file has changed since it was last read. Read it again before editing.';
        runtime.endTool(toolName, error);
        return error;
      }

      runtime.startTool(toolName, filePath);
      var content = tracked.content;
      var replacementsMade = 0;

      for (final rawEdit in editsInput) {
        if (rawEdit is! Map) {
          const error = 'Error: each edit must be an object.';
          runtime.endTool(toolName, error);
          return error;
        }
        final edit = rawEdit.map((key, value) => MapEntry('$key', value));
        final oldText = readString(edit, 'old_text');
        final newText = readString(edit, 'new_text') ?? '';
        final replaceAll = readBool(edit, 'replace_all') ?? false;

        if (oldText == null || oldText.isEmpty) {
          const error = 'Error: every edit must include non-empty `old_text`.';
          runtime.endTool(toolName, error);
          return error;
        }
        if (!content.contains(oldText)) {
          final error = 'Error: could not find text to replace: $oldText';
          runtime.endTool(toolName, error);
          return error;
        }

        if (replaceAll) {
          final matches = RegExp(RegExp.escape(oldText)).allMatches(content).length;
          content = content.replaceAll(oldText, newText);
          replacementsMade += matches;
        } else {
          content = content.replaceFirst(oldText, newText);
          replacementsMade += 1;
        }
      }

      final file = File(filePath);
      await file.writeAsString(content);
      final stat = await file.stat();
      runtime.recordFileRead(file.path, content, stat);

      final output = 'Updated $filePath with $replacementsMade replacement(s).';
      runtime.endTool(toolName, output);
      return output;
    },
  );
}

bool _isAbsolutePath(String path) {
  return path.startsWith('/') || RegExp(r'^[A-Za-z]:[\\/]').hasMatch(path);
}
