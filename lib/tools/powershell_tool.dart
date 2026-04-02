import 'dart:io';

import 'package:genkit/genkit.dart';
import 'package:lea_code/tools/runtime/tool_runtime.dart';
import 'package:schemantic/schemantic.dart';
import 'package:lea_code/tools/utils/legacy_tool_support.dart';

/// Builds the tool that runs a PowerShell command when PowerShell is available.
Tool<JsonMap, String> createPowerShellTool(
  Genkit ai, {
  required ToolRuntime runtime,
}) {
  const toolName = 'powershell';
  return ai.defineTool(
    name: toolName,
    description: 'Executes a PowerShell command.',
    inputSchema: createJsonObjectSchema(
      description: 'Input for the powershell tool.',
      properties: {
        'command': $Schema.string(
          description: 'The PowerShell command to execute.',
        ),
      },
      required: ['command'],
    ),
    outputSchema: stringOutputSchema,
    fn: (input, _) async {
      final command = readString(input, 'command')?.trim();
      if (command == null || command.isEmpty) {
        const error = 'Error: `command` is required.';
        runtime.endTool(toolName, error);
        return error;
      }

      runtime.startTool(toolName, command);

      ProcessResult result;
      try {
        result = await Process.run('pwsh', ['-Command', command]);
      } on ProcessException {
        try {
          result = await Process.run('powershell', ['-Command', command]);
        } on ProcessException {
          const error = 'Error: PowerShell is not available on this machine.';
          runtime.endTool(toolName, error);
          return error;
        }
      }

      final output = '${result.stdout}${result.stderr}'.trimRight();
      runtime.endTool(toolName, output);
      return output;
    },
  );
}
