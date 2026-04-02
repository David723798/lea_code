import 'dart:io';

import 'package:genkit/genkit.dart';
import 'package:lea_code/tools/runtime/tool_runtime.dart';
import 'package:schemantic/schemantic.dart';
import 'package:lea_code/tools/utils/legacy_tool_support.dart';

/// Builds the tool that finds files by wildcard pattern.
Tool<JsonMap, String> createGlobTool(
  Genkit ai, {
  required ToolRuntime runtime,
}) {
  const toolName = 'glob';
  return ai.defineTool(
    name: toolName,
    description: 'Finds files by wildcard pattern, similar to the legacy Glob tool.',
    inputSchema: createJsonObjectSchema(
      description: 'Input for the glob tool.',
      properties: {
        'pattern': $Schema.string(
          description: 'The filename pattern to match, for example "*.dart".',
        ),
        'path': $Schema.string(
          description: 'Optional directory to search. Defaults to ".".',
        ),
      },
      required: ['pattern'],
    ),
    outputSchema: stringOutputSchema,
    fn: (input, _) async {
      final pattern = readString(input, 'pattern')?.trim();
      final path = readString(input, 'path')?.trim();

      if (pattern == null || pattern.isEmpty) {
        const error = 'Error: `pattern` is required.';
        runtime.endTool(toolName, error);
        return error;
      }

      final searchPath = (path == null || path.isEmpty) ? '.' : path;
      runtime.startTool(toolName, '$pattern @ $searchPath');

      final result = await Process.run('find', [searchPath, '-name', pattern]);
      final output = '${result.stdout}${result.stderr}'.trimRight();
      runtime.endTool(toolName, output);
      return output;
    },
  );
}
