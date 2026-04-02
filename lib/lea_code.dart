import 'dart:async';
import 'dart:io';

import 'package:genkit/plugin.dart';
import 'package:lea_code/agents/general_agent.dart';
import 'package:lea_code/tools/models/tool_runtime_models.dart';
import 'package:lea_code/tools/models/tool_status.dart';
import 'package:lea_code/tools/runtime/tool_runtime.dart';

/// The main class for the Lea Code application.
class LeaCode {
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

    final agent = GeneralAgent(
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
        final response = await agent.query(
          trimmed,
          messages: history,
        );

        history = response.messages;

        await responseMessage(response.text);
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
