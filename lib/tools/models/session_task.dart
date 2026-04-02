enum SessionTaskStatus {
  pending,
  inProgress,
  completed,
}

SessionTaskStatus? parseSessionTaskStatus(String? value) {
  switch (value?.trim()) {
    case 'pending':
      return SessionTaskStatus.pending;
    case 'in_progress':
      return SessionTaskStatus.inProgress;
    case 'completed':
      return SessionTaskStatus.completed;
    default:
      return null;
  }
}

String sessionTaskStatusLabel(SessionTaskStatus status) {
  switch (status) {
    case SessionTaskStatus.pending:
      return 'pending';
    case SessionTaskStatus.inProgress:
      return 'in_progress';
    case SessionTaskStatus.completed:
      return 'completed';
  }
}

class SessionTask {
  SessionTask({
    required this.id,
    required this.subject,
    required this.description,
    required this.status,
    this.activeForm,
    this.owner,
    List<String>? blocks,
    List<String>? blockedBy,
    Map<String, dynamic>? metadata,
  }) : blocks = List<String>.from(blocks ?? const <String>[]),
       blockedBy = List<String>.from(blockedBy ?? const <String>[]),
       metadata = Map<String, dynamic>.from(metadata ?? const <String, dynamic>{});

  final String id;
  String subject;
  String description;
  String? activeForm;
  SessionTaskStatus status;
  String? owner;
  final List<String> blocks;
  final List<String> blockedBy;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'subject': subject,
      'description': description,
      if (activeForm != null) 'activeForm': activeForm,
      'status': sessionTaskStatusLabel(status),
      if (owner != null) 'owner': owner,
      'blocks': List<String>.from(blocks),
      'blockedBy': List<String>.from(blockedBy),
      if (metadata.isNotEmpty) 'metadata': Map<String, dynamic>.from(metadata),
    };
  }
}
