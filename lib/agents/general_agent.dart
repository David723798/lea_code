import 'package:genkit/genkit.dart';
import 'package:genkit/plugin.dart';
import 'package:lea_code/tools/ask_user_question_tool.dart';
import 'package:lea_code/tools/bash_tool.dart';
import 'package:lea_code/tools/edit_tool.dart';
import 'package:lea_code/tools/glob_tool.dart';
import 'package:lea_code/tools/grep_tool.dart';
import 'package:lea_code/tools/list_mcp_resources_tool.dart';
import 'package:lea_code/tools/models/tool_status.dart';
import 'package:lea_code/tools/powershell_tool.dart';
import 'package:lea_code/tools/read_mcp_resource_tool.dart';
import 'package:lea_code/tools/read_tool.dart';
import 'package:lea_code/tools/sleep_tool.dart';
import 'package:lea_code/tools/runtime/tool_runtime.dart';
import 'package:lea_code/tools/task_create_tool.dart';
import 'package:lea_code/tools/task_list_tool.dart';
import 'package:lea_code/tools/task_update_tool.dart';
import 'package:lea_code/tools/write_tool.dart';

/// Coordinates the Genkit client and the tool set used by Lea Code.
class GeneralAgent {
  /// The configured Genkit instance used to fulfill model requests.
  late final Genkit ai;

  /// The tool definitions exposed to the model during generation.
  late final List<Tool> tools;

  /// The Gemini model name used for requests.
  final ModelRef model;

  /// The plugin used to fulfill model requests.
  final GenkitPlugin plugin;

  /// The system prompt to use for the agent.
  final String? systemPrompt;

  /// The callback function to handle tool messages.
  final void Function(ToolStatus) onMessage;

  /// Shared runtime for stateful tools.
  final ToolRuntime runtime;

  /// The maximum number of turns to allow in a conversation.
  final int maxTurns;

  /// Creates an agent configured with the provided [model] and [plugin].
  GeneralAgent({
    required this.model,
    required this.plugin,
    required this.onMessage,
    required this.runtime,
    required this.systemPrompt,
    required this.maxTurns,
  }) {
    ai = Genkit(plugins: [plugin]);
    tools = [
      createPowerShellTool(ai, runtime: runtime),
      createGlobTool(ai, runtime: runtime),
      createGrepTool(ai, runtime: runtime),
      createSleepTool(ai, runtime: runtime),
      createBashTool(ai, runtime: runtime),
      createReadTool(ai, runtime: runtime),
      createEditTool(ai, runtime: runtime),
      createWriteTool(ai, runtime: runtime),
      createAskUserQuestionTool(ai, runtime: runtime),
      createTaskCreateTool(ai, runtime: runtime),
      createTaskUpdateTool(ai, runtime: runtime),
      createTaskListTool(ai, runtime: runtime),
      createListMcpResourcesTool(ai, runtime: runtime),
      createReadMcpResourceTool(ai, runtime: runtime),
    ];
  }

  /// Sends [prompt] to the model and returns the generated text response.
  ///
  /// When provided, [messages] are included as prior conversation context.
  Future<GenerateResponseHelper> query(
    String prompt, {
    List<Message>? messages,
  }) async {
    final response = await ai.generate(
      model: model,
      outputInstructions: systemPrompt,
      prompt: prompt,
      messages: messages,
      tools: tools,
      maxTurns: maxTurns,
    );
    return response;
  }
}
