import 'package:genkit/genkit.dart';
import 'package:lea_code/tools/runtime/tool_runtime.dart';
import 'package:lea_code/tools/utils/legacy_tool_support.dart';
import 'package:schemantic/schemantic.dart';

/// Builds the tool that creates a session task.
Tool<JsonMap, JsonMap> createTaskCreateTool(
  Genkit ai, {
  required ToolRuntime runtime,
}) {
  const toolName = 'task_create';
  return ai.defineTool(
    name: toolName,
    description: 'Creates a task in the current session task list.',
    inputSchema: createJsonObjectSchema(
      description: 'Input for the task_create tool.',
      properties: <String, $Schema>{
        'subject': $Schema.string(description: 'Brief task title.'),
        'description': $Schema.string(description: 'What needs to be done.'),
        'activeForm': $Schema.string(
          description: 'Present continuous form for the task, such as "Running tests".',
        ),
        'metadata': $Schema.object(
          description: 'Optional metadata attached to the task.',
          additionalProperties: $Schema.any(),
        ),
      },
      required: <String>['subject', 'description'],
    ),
    outputSchema: createJsonSchema(
      <String, dynamic>{
        'type': 'object',
        'properties': <String, dynamic>{
          'task': <String, dynamic>{
            'type': 'object',
            'additionalProperties': true,
          },
          'error': <String, dynamic>{'type': 'string'},
        },
        'required': <String>['task'],
        'additionalProperties': true,
      },
    ),
    fn: (input, _) async {
      final subject = readString(input, 'subject')?.trim();
      final description = readString(input, 'description')?.trim();
      final activeForm = readString(input, 'activeForm')?.trim();
      final metadata = readJsonMap(input, 'metadata');

      if (subject == null || subject.isEmpty || description == null || description.isEmpty) {
        const error = 'Error: `subject` and `description` are required.';
        runtime.endTool(toolName, error);
        return <String, dynamic>{
          'task': <String, dynamic>{},
          'error': error,
        };
      }

      final task = runtime.createTask(
        subject: subject,
        description: description,
        activeForm: activeForm,
        metadata: metadata,
      );
      final output = task.toJson();
      runtime.endTool(toolName, 'Created task #${task.id}.');
      return <String, dynamic>{'task': output};
    },
  );
}
