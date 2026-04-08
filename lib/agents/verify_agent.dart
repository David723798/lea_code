import 'package:lea_code/agents/base_agent.dart';

/// Reviews the execution output and validates the result.
class VerifyAgent extends BaseAgent with ReadOnlyAgentTools {
  /// Creates a verification-focused agent.
  VerifyAgent({
    required super.model,
    required super.plugin,
    required super.onMessage,
    required super.runtime,
    required super.systemPrompt,
    required super.maxTurns,
  });

  @override
  String get stageInstructions =>
      'You are the verify agent. Validate the implementation against the user '
      'request and the execution report. Run appropriate checks when possible, '
      'then begin your response with exactly one status line: "STATUS: PASS" '
      'or "STATUS: FAIL". After that, explain the verification result, '
      'highlight any remaining issues, and provide the final user-facing '
      'response.';
}
