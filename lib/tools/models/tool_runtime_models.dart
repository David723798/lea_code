class ToolApprovalRequest {
  const ToolApprovalRequest({
    required this.toolName,
    required this.reason,
    required this.command,
  });

  final String toolName;
  final String reason;
  final String command;
}

class ToolQuestionOption {
  const ToolQuestionOption({
    required this.label,
    required this.description,
  });

  final String label;
  final String description;
}

class ToolQuestion {
  const ToolQuestion({
    required this.id,
    required this.header,
    required this.question,
    required this.options,
  });

  final String id;
  final String header;
  final String question;
  final List<ToolQuestionOption> options;
}

class TrackedFileState {
  const TrackedFileState({
    required this.path,
    required this.content,
    required this.lastModified,
    required this.size,
  });

  final String path;
  final String content;
  final DateTime lastModified;
  final int size;
}

class McpResourceDescriptor {
  const McpResourceDescriptor({
    required this.server,
    required this.uri,
    this.name,
    this.description,
    this.mimeType,
  });

  final String server;
  final String uri;
  final String? name;
  final String? description;
  final String? mimeType;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'server': server,
      'uri': uri,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (mimeType != null) 'mimeType': mimeType,
    };
  }
}

class McpResourceContent {
  const McpResourceContent({
    required this.server,
    required this.uri,
    required this.contents,
    this.mimeType,
  });

  final String server;
  final String uri;
  final String contents;
  final String? mimeType;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'server': server,
      'uri': uri,
      'contents': contents,
      if (mimeType != null) 'mimeType': mimeType,
    };
  }
}
