import 'dart:async';
import 'dart:io';

import 'package:genkit/plugin.dart';
import 'package:lea_code/agents/analysis_agent.dart';
import 'package:lea_code/agents/execute_agent.dart';
import 'package:lea_code/agents/verify_agent.dart';
import 'package:lea_code/tools/models/tool_runtime_models.dart';
import 'package:lea_code/tools/models/tool_status.dart';
import 'package:lea_code/tools/runtime/tool_runtime.dart';

/// The main class for the Lea Code application.
class LeaCode {
  static const int maxVerificationAttempts = 3;

  /// Creates a new instance of the Lea Code application.
  const LeaCode({
    required this.model,
    required this.plugin,
    required this.systemPrompt,
    required this.maxTurns,
  });

  /// The model to use for the agent.
  final ModelRef model;

  /// The plugin to use for the agent.
  final GenkitPlugin plugin;

  /// The system prompt to use for the agent.
  final String? systemPrompt;

  /// The maximum number of turns to allow in a conversation.
  final int maxTurns;

  /// Runs the Lea Code application.
  Future<void> run() async {
    await welcomeMessage();

    final runtime = ToolRuntime(
      onMessage: toolMessage,
      requestApproval: requestApproval,
      askQuestions: askQuestions,
      workspaceRoot: Directory.current.path,
      currentWorkingDirectory: Directory.current.path,
    );

    final analysisAgent = AnalysisAgent(
      model: model,
      plugin: plugin,
      onMessage: toolMessage,
      runtime: runtime,
      systemPrompt: systemPrompt,
      maxTurns: maxTurns,
    );
    final executeAgent = ExecuteAgent(
      model: model,
      plugin: plugin,
      onMessage: toolMessage,
      runtime: runtime,
      systemPrompt: systemPrompt,
      maxTurns: maxTurns,
    );
    final verifyAgent = VerifyAgent(
      model: model,
      plugin: plugin,
      onMessage: toolMessage,
      runtime: runtime,
      systemPrompt: systemPrompt,
      maxTurns: maxTurns,
    );

    List<Message>? history;

    while (true) {
      await inputMessage();
      final input = stdin.readLineSync();

      final trimmed = input?.trim();

      if (trimmed == null || trimmed.toLowerCase() == '/exit') {
        break;
      }

      if (trimmed.isEmpty) {
        continue;
      }

      if (trimmed == '/new') {
        history = null;
        await newConversationMessage();
        continue;
      }

      try {
        await thinkingMessage();
        final analysis = await analysisAgent.query(
          trimmed,
          messages: history,
        );
        GenerateResponseHelper? execution;
        GenerateResponseHelper? verification;
        VerificationStatus verificationStatus = VerificationStatus.fail;
        String? verificationFeedback;

        for (var attempt = 1; attempt <= maxVerificationAttempts; attempt++) {
          execution = await executeAgent.query(
            buildExecutionPrompt(
              userRequest: trimmed,
              analysis: analysis.text,
              attempt: attempt,
              previousExecution: execution?.text,
              verificationFeedback: verificationFeedback,
            ),
            messages: history,
          );
          verification = await verifyAgent.query(
            buildVerificationPrompt(
              userRequest: trimmed,
              analysis: analysis.text,
              execution: execution.text,
              attempt: attempt,
            ),
            messages: history,
          );
          verificationStatus = parseVerificationStatus(verification.text);
          verificationFeedback = stripVerificationStatus(verification.text);

          if (verificationStatus == VerificationStatus.pass) {
            break;
          }
        }

        history = verification?.messages;

        await responseMessage(verificationFeedback ?? verification?.text ?? '');
      } catch (e) {
        await errorMessage(e);
      }
    }

    await exitMessage();
  }

  /// Displays a welcome message to the user.
  Future<void> welcomeMessage() async {
    stdout.writeln('--- Lea Code ---');
    stdout.writeln('Using model: ${model.name}');
    stdout.writeln('Type "/exit" to leave.');
    stdout.writeln('Type "/new" to clear history and start fresh.');
  }

  /// Displays a goodbye message to the user.
  Future<void> exitMessage() async {
    stdout.writeln('Goodbye!');
  }

  /// Displays a message indicating a new conversation has started.
  Future<void> newConversationMessage() async {
    stdout.writeln('Started a new conversation.');
  }

  /// Displays a message indicating the model is thinking.
  Future<void> thinkingMessage() async {
    stdout.writeln('Thinking...');
  }

  /// Builds the execution prompt from the analysis result.
  String buildExecutionPrompt({
    required String userRequest,
    required String analysis,
    required int attempt,
    String? previousExecution,
    String? verificationFeedback,
  }) {
    final retryContext = switch (attempt) {
      1 => 'This is the first execution attempt.',
      _ =>
        '''
This is retry attempt $attempt of $maxVerificationAttempts.

Previous execution report:
${previousExecution ?? 'None'}

Verification feedback from the last attempt:
${verificationFeedback ?? 'None'}

Address every failure the verifier identified before finishing.
''',
    };

    return '''
User request:
$userRequest

Analysis:
$analysis

Retry context:
$retryContext

Carry out the request. Apply the necessary changes and summarize what you changed.
''';
  }

  /// Builds the verification prompt from the analysis and execution results.
  String buildVerificationPrompt({
    required String userRequest,
    required String analysis,
    required String execution,
    required int attempt,
  }) {
    return '''
User request:
$userRequest

Analysis:
$analysis

Execution report:
$execution

Verification attempt:
$attempt of $maxVerificationAttempts

Verify whether the request is fully satisfied. Start with exactly "STATUS: PASS" or "STATUS: FAIL". Run checks when useful, call out any remaining gaps, and provide the final user-facing response.
''';
  }

  /// Parses the verification status from the verifier response.
  VerificationStatus parseVerificationStatus(String response) {
    final normalized = response.trimLeft().toUpperCase();
    if (normalized.startsWith('STATUS: PASS')) {
      return VerificationStatus.pass;
    }
    return VerificationStatus.fail;
  }

  /// Removes the status line from the verifier response before displaying it.
  String stripVerificationStatus(String response) {
    final lines = response.split('\n');
    if (lines.isEmpty) {
      return response;
    }
    if (lines.first.trim().toUpperCase().startsWith('STATUS:')) {
      return lines.skip(1).join('\n').trim();
    }
    return response.trim();
  }

  /// Displays the model's response to the user.
  Future<void> responseMessage(String response) async {
    stdout.writeln(response);
  }

  /// Displays an error message to the user.
  Future<void> errorMessage(Object error) async {
    stdout.writeln('Error: $error');
  }

  /// Displays a prompt for the user to enter input.
  Future<void> inputMessage() async {
    stdout.write('> ');
  }

  /// Displays a message indicating the tool has started or completed.
  Future<void> toolMessage(ToolStatus toolStatus) async {
    if (toolStatus is ToolStatusEnd) {
      stdout.writeln('[${toolStatus.name}] completed');
    } else {
      stdout.writeln('[${toolStatus.name}] ${toolStatus.message}');
    }
  }

  Future<bool> requestApproval(ToolApprovalRequest request) async {
    stdout.writeln('[${request.toolName}] Approval required');
    stdout.writeln('Reason: ${request.reason}');
    stdout.writeln('Command: ${request.command}');
    stdout.write('Allow? [y/N]: ');
    final response = stdin.readLineSync()?.trim().toLowerCase() ?? '';
    return response == 'y' || response == 'yes';
  }

  Future<Map<String, String>> askQuestions(List<ToolQuestion> questions) async {
    final answers = <String, String>{};
    for (final question in questions) {
      stdout.writeln('[question] ${question.header}');
      stdout.writeln(question.question);
      for (var index = 0; index < question.options.length; index++) {
        final option = question.options[index];
        stdout.writeln(
          '${index + 1}. ${option.label} - ${option.description}',
        );
      }

      while (true) {
        stdout.write('Choose 1-${question.options.length}: ');
        final response = stdin.readLineSync()?.trim() ?? '';
        final selectedIndex = int.tryParse(response);
        if (selectedIndex != null && selectedIndex >= 1 && selectedIndex <= question.options.length) {
          answers[question.id] = question.options[selectedIndex - 1].label;
          break;
        }
        stdout.writeln('Please enter a valid option number.');
      }
    }
    return answers;
  }
}

enum VerificationStatus {
  pass,
  fail,
}
