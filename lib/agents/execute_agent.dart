import 'package:lea_code/agents/base_agent.dart';

/// Applies the requested changes using the available tools.
class ExecuteAgent extends BaseAgent with FullAccessAgentTools {
  /// Creates an execution-focused agent.
  ExecuteAgent({
    required super.model,
    required super.plugin,
    required super.onMessage,
    required super.runtime,
    required super.systemPrompt,
    required super.maxTurns,
  });

  @override
  String get stageInstructions =>
      'You are the execute agent. Use the analysis you receive to make the '
      'necessary code or workspace changes. Prefer minimal, targeted edits and '
      'report exactly what changed and what still needs verification.';
}
