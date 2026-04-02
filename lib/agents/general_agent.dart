import 'package:genkit/genkit.dart';
import 'package:genkit/plugin.dart';
import 'package:lea_code/tools/file_edit_tool.dart';
import 'package:lea_code/tools/file_find.dart';
import 'package:lea_code/tools/models/tool_status.dart';
import 'package:lea_code/tools/string_search_tool.dart';
import 'package:lea_code/tools/web_fetch_tool.dart';
import '../tools/bash_tool.dart';
import '../tools/file_read_tool.dart';
import '../tools/file_write_tool.dart';

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

  /// The maximum number of turns to allow in a conversation.
  final int maxTurns;

  /// Creates an agent configured with the provided [model] and [plugin].
  GeneralAgent({
    required this.model,
    required this.plugin,
    required this.onMessage,
    required this.systemPrompt,
    required this.maxTurns,
  }) {
    ai = Genkit(plugins: [plugin]);
    tools = [
      createBashTool(ai, onMessage: onMessage),
      createFileReadTool(ai, onMessage: onMessage),
      createFileWriteTool(ai, onMessage: onMessage),
      createFileEditTool(ai, onMessage: onMessage),
      createStringSearchTool(ai, onMessage: onMessage),
      createFileFindTool(ai, onMessage: onMessage),
      createWebFetchTool(ai, onMessage: onMessage),
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
