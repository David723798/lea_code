import 'dart:io';

import 'package:genkit/genkit.dart';
import 'package:lea_code/tools/runtime/tool_runtime.dart';
import 'package:schemantic/schemantic.dart';
import 'package:lea_code/tools/utils/legacy_tool_support.dart';

/// Builds the tool that searches file contents using ripgrep-style arguments.
Tool<JsonMap, String> createGrepTool(
  Genkit ai, {
  required ToolRuntime runtime,
}) {
  const toolName = 'grep';
  return ai.defineTool(
    name: toolName,
    description: 'Searches file contents with regular expressions, similar to the legacy Grep tool.',
    inputSchema: createJsonObjectSchema(
      description: 'Input for the grep tool.',
      properties: {
        'pattern': $Schema.string(
          description: 'The regular expression or literal pattern to search for.',
        ),
        'path': $Schema.string(
          description: 'Optional file or directory to search. Defaults to ".".',
        ),
        'glob': $Schema.string(
          description: 'Optional ripgrep glob filter, for example "*.dart".',
        ),
        'output_mode': $Schema.string(
          description: 'One of "content", "files_with_matches", or "count".',
        ),
        '-i': $Schema.boolean(
          description: 'Whether to search case-insensitively.',
        ),
        'head_limit': $Schema.integer(
          description: 'Optional maximum number of lines to return.',
        ),
      },
      required: ['pattern'],
    ),
    outputSchema: stringOutputSchema,
    fn: (input, _) async {
      final pattern = readString(input, 'pattern')?.trim();
      final path = readString(input, 'path')?.trim();
      final glob = readString(input, 'glob')?.trim();
      final outputMode = readString(input, 'output_mode')?.trim() ?? 'files_with_matches';
      final isCaseInsensitive = readBool(input, '-i') ?? false;
      final headLimit = readInt(input, 'head_limit');

      if (pattern == null || pattern.isEmpty) {
        const error = 'Error: `pattern` is required.';
        runtime.endTool(toolName, error);
        return error;
      }

      final searchPath = (path == null || path.isEmpty) ? '.' : path;
      final args = <String>[
        if (outputMode == 'files_with_matches') '-l',
        if (outputMode == 'count') '-c',
        if (outputMode == 'content') '-n',
        if (isCaseInsensitive) '-i',
        if (glob != null && glob.isNotEmpty) '--glob',
        if (glob != null && glob.isNotEmpty) glob,
        pattern,
        searchPath,
      ];

      runtime.startTool(toolName, '$pattern @ $searchPath');

      final result = await Process.run('rg', args);
      final exitCode = result.exitCode;
      var output = '${result.stdout}${result.stderr}'.trimRight();

      if (exitCode == 1 && output.isEmpty) {
        output = 'No matches found.';
      } else if (exitCode > 1 && output.isEmpty) {
        output = 'Error: grep command failed with exit code $exitCode.';
      }

      if (headLimit != null && headLimit > 0) {
        final lines = output.split('\n');
        output = lines.take(headLimit).join('\n');
      }

      runtime.endTool(toolName, output);
      return output;
    },
  );
}
