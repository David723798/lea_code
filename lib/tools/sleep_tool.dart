import 'dart:async';

import 'package:genkit/genkit.dart';
import 'package:lea_code/tools/runtime/tool_runtime.dart';
import 'package:schemantic/schemantic.dart';
import 'package:lea_code/tools/utils/legacy_tool_support.dart';

/// Builds the tool that waits for a requested duration.
Tool<JsonMap, String> createSleepTool(
  Genkit ai, {
  required ToolRuntime runtime,
}) {
  const toolName = 'sleep';
  return ai.defineTool(
    name: toolName,
    description: 'Waits for a specified duration.',
    inputSchema: createJsonObjectSchema(
      description: 'Input for the sleep tool.',
      properties: {
        'duration_ms': $Schema.integer(
          description: 'The number of milliseconds to wait.',
        ),
        'seconds': $Schema.integer(
          description: 'The number of seconds to wait.',
        ),
      },
    ),
    outputSchema: stringOutputSchema,
    fn: (input, _) async {
      final durationMs = readInt(input, 'duration_ms') ?? ((readInt(input, 'seconds') ?? 1) * 1000);
      final safeDurationMs = durationMs < 0 ? 0 : durationMs;

      runtime.startTool(toolName, 'Sleeping for $safeDurationMs ms');
      await Future<void>.delayed(Duration(milliseconds: safeDurationMs));

      final output = 'Slept for $safeDurationMs ms.';
      runtime.endTool(toolName, output);
      return output;
    },
  );
}
