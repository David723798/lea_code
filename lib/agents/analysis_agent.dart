import 'package:lea_code/agents/base_agent.dart';

/// Plans the work before any execution happens.
class AnalysisAgent extends BaseAgent with ReadOnlyAgentTools {
  /// Creates an analysis-focused agent.
  AnalysisAgent({
    required super.model,
    required super.plugin,
    required super.onMessage,
    required super.runtime,
    required super.systemPrompt,
    required super.maxTurns,
  });

  @override
  String get stageInstructions =>
      'You are the analysis agent. Understand the request, inspect the codebase, '
      'and produce a concise execution plan. Do not modify files. Call out any '
      'risks, assumptions, and the expected validation steps for the executor.';
}
