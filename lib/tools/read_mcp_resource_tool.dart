import 'package:genkit/genkit.dart';
import 'package:lea_code/tools/runtime/tool_runtime.dart';
import 'package:lea_code/tools/utils/legacy_tool_support.dart';
import 'package:schemantic/schemantic.dart';

/// Builds the tool that reads a specific MCP resource.
Tool<JsonMap, JsonMap> createReadMcpResourceTool(
  Genkit ai, {
  required ToolRuntime runtime,
}) {
  const toolName = 'read_mcp_resource';
  return ai.defineTool(
    name: toolName,
    description: 'Reads a specific resource from the configured MCP backend.',
    inputSchema: createJsonObjectSchema(
      description: 'Input for the read_mcp_resource tool.',
      properties: <String, $Schema>{
        'server': $Schema.string(description: 'MCP server name.'),
        'uri': $Schema.string(description: 'MCP resource URI.'),
      },
      required: <String>['server', 'uri'],
    ),
    outputSchema: createJsonSchema(
      <String, dynamic>{
        'type': 'object',
        'properties': <String, dynamic>{
          'resource': <String, dynamic>{
            'type': 'object',
            'additionalProperties': true,
          },
          'error': <String, dynamic>{'type': 'string'},
        },
        'required': <String>['resource'],
        'additionalProperties': true,
      },
    ),
    fn: (input, _) async {
      final adapter = runtime.mcpResourceAdapter;
      if (adapter == null) {
        const error = 'Error: MCP unavailable for this session.';
        runtime.endTool(toolName, error);
        return <String, dynamic>{
          'resource': <String, dynamic>{},
          'error': error,
        };
      }

      final server = readString(input, 'server')?.trim();
      final uri = readString(input, 'uri')?.trim();
      if (server == null || server.isEmpty || uri == null || uri.isEmpty) {
        const error = 'Error: `server` and `uri` are required.';
        runtime.endTool(toolName, error);
        return <String, dynamic>{
          'resource': <String, dynamic>{},
          'error': error,
        };
      }

      try {
        final resource = await adapter.readResource(server: server, uri: uri);
        runtime.endTool(toolName, 'Read MCP resource $uri from $server.');
        return <String, dynamic>{
          'resource': resource.toJson(),
        };
      } catch (error) {
        final message = 'Error: $error';
        runtime.endTool(toolName, message);
        return <String, dynamic>{
          'resource': <String, dynamic>{},
          'error': message,
        };
      }
    },
  );
}
