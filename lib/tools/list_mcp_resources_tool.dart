import 'package:genkit/genkit.dart';
import 'package:lea_code/tools/runtime/tool_runtime.dart';
import 'package:lea_code/tools/utils/legacy_tool_support.dart';
import 'package:schemantic/schemantic.dart';

/// Builds the tool that lists available MCP resources.
Tool<JsonMap, JsonMap> createListMcpResourcesTool(
  Genkit ai, {
  required ToolRuntime runtime,
}) {
  const toolName = 'list_mcp_resources';
  return ai.defineTool(
    name: toolName,
    description: 'Lists available resources from the configured MCP backend.',
    inputSchema: createJsonObjectSchema(
      description: 'Input for the list_mcp_resources tool.',
      properties: <String, $Schema>{
        'server': $Schema.string(
          description: 'Optional server name to filter resources.',
        ),
      },
    ),
    outputSchema: createJsonSchema(
      <String, dynamic>{
        'type': 'object',
        'properties': <String, dynamic>{
          'resources': <String, dynamic>{
            'type': 'array',
            'items': <String, dynamic>{
              'type': 'object',
              'additionalProperties': true,
            },
          },
          'error': <String, dynamic>{'type': 'string'},
        },
        'required': <String>['resources'],
        'additionalProperties': true,
      },
    ),
    fn: (input, _) async {
      final adapter = runtime.mcpResourceAdapter;
      if (adapter == null) {
        const error = 'Error: MCP unavailable for this session.';
        runtime.endTool(toolName, error);
        return <String, dynamic>{
          'resources': <Map<String, dynamic>>[],
          'error': error,
        };
      }

      final server = readString(input, 'server')?.trim();
      final resources = await adapter.listResources(server: server);
      runtime.endTool(toolName, 'Listed ${resources.length} MCP resource(s).');
      return <String, dynamic>{
        'resources': resources.map((resource) => resource.toJson()).toList(),
      };
    },
  );
}
