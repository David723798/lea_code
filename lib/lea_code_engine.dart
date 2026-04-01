import 'package:genkit/genkit.dart';
import 'package:genkit_google_genai/genkit_google_genai.dart';
import 'package:lea_code/tools/file_find.dart';
import 'package:lea_code/tools/string_search_tool.dart';
import 'package:lea_code/tools/web_fetch_tool.dart';
import 'tools/bash_tool.dart';
import 'tools/file_read_tool.dart';
import 'tools/file_write_tool.dart';

/// Coordinates the Genkit client and the tool set used by Lea Code.
class LeaCodeEngine {
  /// The configured Genkit instance used to fulfill model requests.
  late final Genkit ai;

  /// The tool definitions exposed to the model during generation.
  late final List<Tool> tools;

  /// The Gemini model name used for requests.
  final String modelName;

  /// Creates an engine configured with the provided Gemini [modelName].
  LeaCodeEngine({required this.modelName}) {
    ai = Genkit(plugins: [googleAI()]);
    tools = [
      createBashTool(ai),
      createFileReadTool(ai),
      createFileWriteTool(ai),
      createStringSearchTool(ai),
      createFileFindTool(ai),
      createWebFetchTool(ai),
    ];
  }

  /// Sends [prompt] to the model and returns the generated text response.
  ///
  /// When provided, [messages] are included as prior conversation context.
  Future<String> query(String prompt, {List<Message>? messages}) async {
    final response = await ai.generate(
      model: googleAI.gemini(modelName),
      prompt: prompt,
      messages: messages,
      tools: tools,
    );
    return response.text;
  }
}
