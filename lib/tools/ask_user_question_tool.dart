import 'package:genkit/genkit.dart';
import 'package:lea_code/tools/models/tool_runtime_models.dart';
import 'package:lea_code/tools/runtime/tool_runtime.dart';
import 'package:lea_code/tools/utils/legacy_tool_support.dart';

/// Builds the tool that asks the user multiple-choice questions.
Tool<JsonMap, JsonMap> createAskUserQuestionTool(
  Genkit ai, {
  required ToolRuntime runtime,
}) {
  const toolName = 'ask_user_question';
  return ai.defineTool(
    name: toolName,
    description: 'Asks the user one to three multiple-choice questions.',
    inputSchema: createJsonSchema(
      <String, dynamic>{
        'type': 'object',
        'description': 'Input for the ask_user_question tool.',
        'properties': <String, dynamic>{
          'questions': <String, dynamic>{
            'type': 'array',
            'items': <String, dynamic>{
              'type': 'object',
              'properties': <String, dynamic>{
                'id': <String, dynamic>{'type': 'string'},
                'header': <String, dynamic>{'type': 'string'},
                'question': <String, dynamic>{'type': 'string'},
                'options': <String, dynamic>{
                  'type': 'array',
                  'items': <String, dynamic>{
                    'type': 'object',
                    'properties': <String, dynamic>{
                      'label': <String, dynamic>{'type': 'string'},
                      'description': <String, dynamic>{'type': 'string'},
                    },
                    'required': <String>['label', 'description'],
                    'additionalProperties': false,
                  },
                },
              },
              'required': <String>['id', 'header', 'question', 'options'],
              'additionalProperties': false,
            },
          },
        },
        'required': <String>['questions'],
        'additionalProperties': false,
      },
    ),
    outputSchema: createJsonSchema(
      <String, dynamic>{
        'type': 'object',
        'properties': <String, dynamic>{
          'answers': <String, dynamic>{
            'type': 'object',
            'additionalProperties': <String, dynamic>{'type': 'string'},
          },
        },
        'required': <String>['answers'],
        'additionalProperties': false,
      },
    ),
    fn: (input, _) async {
      final questionsInput = readList(input, 'questions');
      if (questionsInput == null || questionsInput.isEmpty || questionsInput.length > 3) {
        const error = 'Error: `questions` must contain between 1 and 3 questions.';
        runtime.endTool(toolName, error);
        return <String, dynamic>{
          'answers': <String, String>{},
          'error': error,
        };
      }

      final parsedQuestions = <ToolQuestion>[];
      for (final rawQuestion in questionsInput) {
        if (rawQuestion is! Map) {
          const error = 'Error: each question must be an object.';
          runtime.endTool(toolName, error);
          return <String, dynamic>{
            'answers': <String, String>{},
            'error': error,
          };
        }

        final question = rawQuestion.map((key, value) => MapEntry('$key', value));
        final id = readString(question, 'id')?.trim();
        final header = readString(question, 'header')?.trim();
        final text = readString(question, 'question')?.trim();
        final optionsInput = readList(question, 'options');
        if (id == null ||
            id.isEmpty ||
            header == null ||
            header.isEmpty ||
            text == null ||
            text.isEmpty ||
            optionsInput == null ||
            optionsInput.length < 2 ||
            optionsInput.length > 4) {
          const error = 'Error: every question needs id, header, question, and 2-4 options.';
          runtime.endTool(toolName, error);
          return <String, dynamic>{
            'answers': <String, String>{},
            'error': error,
          };
        }

        final parsedOptions = <ToolQuestionOption>[];
        for (final rawOption in optionsInput) {
          if (rawOption is! Map) {
            const error = 'Error: each option must be an object.';
            runtime.endTool(toolName, error);
            return <String, dynamic>{
              'answers': <String, String>{},
              'error': error,
            };
          }
          final option = rawOption.map((key, value) => MapEntry('$key', value));
          final label = readString(option, 'label')?.trim();
          final description = readString(option, 'description')?.trim();
          if (label == null || label.isEmpty || description == null || description.isEmpty) {
            const error = 'Error: every option needs non-empty `label` and `description`.';
            runtime.endTool(toolName, error);
            return <String, dynamic>{
              'answers': <String, String>{},
              'error': error,
            };
          }
          parsedOptions.add(
            ToolQuestionOption(label: label, description: description),
          );
        }

        parsedQuestions.add(
          ToolQuestion(
            id: id,
            header: header,
            question: text,
            options: parsedOptions,
          ),
        );
      }

      runtime.startTool(toolName, 'Waiting for user answers');
      final answers = await runtime.askQuestions(parsedQuestions);
      runtime.endTool(
        toolName,
        answers.entries.map((entry) => '${entry.key}: ${entry.value}').join(', '),
      );
      return <String, dynamic>{
        'answers': answers,
      };
    },
  );
}
