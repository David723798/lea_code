import 'package:genkit/genkit.dart';
import 'package:lea_code/tools/runtime/tool_runtime.dart';
import 'package:lea_code/tools/utils/legacy_tool_support.dart';

/// Builds the tool that lists all session tasks.
Tool<JsonMap, JsonMap> createTaskListTool(
  Genkit ai, {
  required ToolRuntime runtime,
}) {
  const toolName = 'task_list';
  return ai.defineTool(
    name: toolName,
    description: 'Lists tasks in the current session.',
    inputSchema: createJsonObjectSchema(
      description: 'Input for the task_list tool.',
    ),
    outputSchema: createJsonSchema(
      <String, dynamic>{
        'type': 'object',
        'properties': <String, dynamic>{
          'tasks': <String, dynamic>{
            'type': 'array',
            'items': <String, dynamic>{
              'type': 'object',
              'additionalProperties': true,
            },
          },
        },
        'required': <String>['tasks'],
        'additionalProperties': false,
      },
    ),
    fn: (_, _) async {
      final tasks = runtime.listTasks().map((task) => task.toJson()).toList();
      runtime.endTool(toolName, 'Listed ${tasks.length} task(s).');
      return <String, dynamic>{'tasks': tasks};
    },
  );
}
