import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:genkit/genkit.dart';
import 'package:lea_code/tools/models/tool_runtime_models.dart';
import 'package:lea_code/tools/runtime/tool_runtime.dart';
import 'package:lea_code/tools/utils/command_safety.dart';
import 'package:lea_code/tools/utils/legacy_tool_support.dart';
import 'package:schemantic/schemantic.dart';

/// Builds the tool that runs shell commands in the workspace.
Tool<JsonMap, String> createBashTool(
  Genkit ai, {
  required ToolRuntime runtime,
}) {
  const toolName = 'bash';
  return ai.defineTool(
    name: toolName,
    description: 'Runs a shell command in the current workspace.',
    inputSchema: createJsonObjectSchema(
      description: 'Input for the bash tool.',
      properties: <String, $Schema>{
        'command': $Schema.string(
          description: 'The shell command to execute.',
        ),
        'workdir': $Schema.string(
          description: 'Optional working directory. Defaults to the current workspace directory.',
        ),
        'timeout_ms': $Schema.integer(
          description: 'Optional timeout in milliseconds. Defaults to 30000.',
        ),
      },
      required: <String>['command'],
    ),
    outputSchema: stringOutputSchema,
    fn: (input, _) async {
      final command = readString(input, 'command')?.trim();
      final workdirInput = readString(input, 'workdir')?.trim();
      final timeoutMs = readInt(input, 'timeout_ms') ?? 30000;

      if (command == null || command.isEmpty) {
        const error = 'Error: `command` is required.';
        runtime.endTool(toolName, error);
        return error;
      }

      final workdir = workdirInput == null || workdirInput.isEmpty
          ? runtime.currentWorkingDirectory
          : runtime.resolveDirectory(workdirInput);
      if (!runtime.isWithinWorkspace(workdir)) {
        const error = 'Error: `workdir` must stay inside the workspace.';
        runtime.endTool(toolName, error);
        return error;
      }

      final assessment = assessBashCommand(command);
      if (assessment.requiresApproval) {
        final approved = await runtime.requestApproval(
          ToolApprovalRequest(
            toolName: toolName,
            reason: assessment.reason ?? 'This command requires approval.',
            command: command,
          ),
        );
        if (!approved) {
          const rejected = 'Error: command was not approved by the user.';
          runtime.endTool(toolName, rejected);
          return rejected;
        }
      }

      runtime.startTool(toolName, '$command @ $workdir');
      final output = await _runCommand(
        command: command,
        workdir: workdir,
        timeoutMs: timeoutMs < 1 ? 1 : timeoutMs,
      );
      runtime.endTool(toolName, output);
      return output;
    },
  );
}

Future<String> _runCommand({
  required String command,
  required String workdir,
  required int timeoutMs,
}) async {
  final shell = Platform.isWindows ? 'cmd' : '/bin/zsh';
  final shellArgs = Platform.isWindows ? <String>['/c', command] : <String>['-lc', command];
  final process = await Process.start(
    shell,
    shellArgs,
    workingDirectory: workdir,
  );

  final stdoutFuture = process.stdout.transform(utf8.decoder).join();
  final stderrFuture = process.stderr.transform(utf8.decoder).join();

  try {
    final exitCode = await process.exitCode.timeout(
      Duration(milliseconds: timeoutMs),
    );
    final stdoutOutput = (await stdoutFuture).trimRight();
    final stderrOutput = (await stderrFuture).trimRight();
    return _formatCommandOutput(
      exitCode: exitCode,
      stdoutOutput: stdoutOutput,
      stderrOutput: stderrOutput,
    );
  } on TimeoutException {
    process.kill(ProcessSignal.sigkill);
    final stdoutOutput = (await stdoutFuture).trimRight();
    final stderrOutput = (await stderrFuture).trimRight();
    final timedOutMessage = 'Command timed out after $timeoutMs ms.';
    return _formatCommandOutput(
      exitCode: null,
      stdoutOutput: stdoutOutput,
      stderrOutput: stderrOutput.isEmpty ? timedOutMessage : '$stderrOutput\n$timedOutMessage',
    );
  }
}

String _formatCommandOutput({
  required int? exitCode,
  required String stdoutOutput,
  required String stderrOutput,
}) {
  final buffer = StringBuffer()
    ..writeln('exit_code: ${exitCode ?? 'timeout'}')
    ..writeln('stdout:');
  if (stdoutOutput.isEmpty) {
    buffer.writeln('<empty>');
  } else {
    buffer.writeln(stdoutOutput);
  }
  buffer.writeln('stderr:');
  if (stderrOutput.isEmpty) {
    buffer.write('<empty>');
  } else {
    buffer.write(stderrOutput);
  }
  return buffer.toString().trimRight();
}
