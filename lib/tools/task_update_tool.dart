import 'package:genkit/genkit.dart';
import 'package:lea_code/tools/models/session_task.dart';
import 'package:lea_code/tools/runtime/tool_runtime.dart';
import 'package:lea_code/tools/utils/legacy_tool_support.dart';

/// Builds the tool that updates a session task.
Tool<JsonMap, JsonMap> createTaskUpdateTool(
  Genkit ai, {
  required ToolRuntime runtime,
}) {
  const toolName = 'task_update';
  return ai.defineTool(
    name: toolName,
    description: 'Updates an existing task in the current session.',
    inputSchema: createJsonSchema(
      <String, dynamic>{
        'type': 'object',
        'description': 'Input for the task_update tool.',
        'properties': <String, dynamic>{
          'taskId': <String, dynamic>{'type': 'string'},
          'subject': <String, dynamic>{'type': 'string'},
          'description': <String, dynamic>{'type': 'string'},
          'activeForm': <String, dynamic>{'type': 'string'},
          'status': <String, dynamic>{'type': 'string'},
          'owner': <String, dynamic>{'type': 'string'},
          'addBlocks': <String, dynamic>{
            'type': 'array',
            'items': <String, dynamic>{'type': 'string'},
          },
          'addBlockedBy': <String, dynamic>{
            'type': 'array',
            'items': <String, dynamic>{'type': 'string'},
          },
          'metadata': <String, dynamic>{
            'type': 'object',
            'additionalProperties': true,
          },
        },
        'required': <String>['taskId'],
        'additionalProperties': false,
      },
    ),
    outputSchema: createJsonSchema(
      <String, dynamic>{
        'type': 'object',
        'properties': <String, dynamic>{
          'success': <String, dynamic>{'type': 'boolean'},
          'task': <String, dynamic>{
            'type': 'object',
            'additionalProperties': true,
          },
          'error': <String, dynamic>{'type': 'string'},
        },
        'required': <String>['success'],
        'additionalProperties': true,
      },
    ),
    fn: (input, _) async {
      final taskId = readString(input, 'taskId')?.trim();
      if (taskId == null || taskId.isEmpty) {
        const error = 'Error: `taskId` is required.';
        runtime.endTool(toolName, error);
        return <String, dynamic>{'success': false, 'error': error};
      }

      final task = runtime.taskById(taskId);
      if (task == null) {
        final error = 'Error: task #$taskId was not found.';
        runtime.endTool(toolName, error);
        return <String, dynamic>{'success': false, 'error': error};
      }

      final newStatus = parseSessionTaskStatus(readString(input, 'status'));
      if (readString(input, 'status') != null && newStatus == null) {
        const error = 'Error: `status` must be pending, in_progress, or completed.';
        runtime.endTool(toolName, error);
        return <String, dynamic>{'success': false, 'error': error};
      }

      final validationError = runtime.validateTaskTransition(
        taskId: taskId,
        newStatus: newStatus,
      );
      if (validationError != null) {
        runtime.endTool(toolName, validationError);
        return <String, dynamic>{
          'success': false,
          'error': validationError,
        };
      }

      final subject = readString(input, 'subject')?.trim();
      final description = readString(input, 'description')?.trim();
      final activeForm = readString(input, 'activeForm')?.trim();
      final owner = readString(input, 'owner')?.trim();
      final addBlocks = readList(input, 'addBlocks');
      final addBlockedBy = readList(input, 'addBlockedBy');
      final metadata = readJsonMap(input, 'metadata');

      if (subject != null && subject.isNotEmpty) {
        task.subject = subject;
      }
      if (description != null && description.isNotEmpty) {
        task.description = description;
      }
      if (activeForm != null && activeForm.isNotEmpty) {
        task.activeForm = activeForm;
      }
      if (owner != null && owner.isNotEmpty) {
        task.owner = owner;
      }
      if (newStatus != null) {
        task.status = newStatus;
      }
      if (addBlocks != null) {
        for (final id in addBlocks) {
          final value = '$id'.trim();
          if (value.isNotEmpty && !task.blocks.contains(value)) {
            task.blocks.add(value);
          }
        }
      }
      if (addBlockedBy != null) {
        for (final id in addBlockedBy) {
          final value = '$id'.trim();
          if (value.isNotEmpty && !task.blockedBy.contains(value)) {
            task.blockedBy.add(value);
          }
        }
      }
      if (metadata != null) {
        for (final entry in metadata.entries) {
          if (entry.value == null) {
            task.metadata.remove(entry.key);
          } else {
            task.metadata[entry.key] = entry.value;
          }
        }
      }

      runtime.endTool(toolName, 'Updated task #${task.id}.');
      return <String, dynamic>{
        'success': true,
        'task': task.toJson(),
      };
    },
  );
}
