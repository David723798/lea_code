sealed class ToolStatus {
  const ToolStatus({
    required this.name,
    required this.message,
  });

  final String name;
  final String message;
}

class ToolStatusStart extends ToolStatus {
  const ToolStatusStart({
    required super.name,
    required super.message,
  });
}

class ToolStatusEnd extends ToolStatus {
  const ToolStatusEnd({
    required super.name,
    required super.message,
  });
}
