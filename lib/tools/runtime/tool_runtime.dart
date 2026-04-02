import 'dart:io';

import 'package:lea_code/tools/models/session_task.dart';
import 'package:lea_code/tools/models/tool_runtime_models.dart';
import 'package:lea_code/tools/models/tool_status.dart';

abstract class McpResourceAdapter {
  Future<List<McpResourceDescriptor>> listResources({String? server});

  Future<McpResourceContent> readResource({
    required String server,
    required String uri,
  });
}

class ToolRuntime {
  ToolRuntime({
    required this.onMessage,
    required this.requestApproval,
    required this.askQuestions,
    required this.workspaceRoot,
    String? currentWorkingDirectory,
    this.mcpResourceAdapter,
  }) : currentWorkingDirectory = _normalizeDirectoryPath(
         currentWorkingDirectory ?? workspaceRoot,
       );

  final void Function(ToolStatus status) onMessage;
  final Future<bool> Function(ToolApprovalRequest request) requestApproval;
  final Future<Map<String, String>> Function(List<ToolQuestion> questions) askQuestions;
  final String workspaceRoot;
  String currentWorkingDirectory;
  final McpResourceAdapter? mcpResourceAdapter;

  final Map<String, TrackedFileState> _trackedFiles = <String, TrackedFileState>{};
  final Map<String, SessionTask> _tasks = <String, SessionTask>{};
  int _nextTaskId = 1;

  void startTool(String name, String message) {
    onMessage(ToolStatusStart(name: name, message: message));
  }

  void endTool(String name, String message) {
    onMessage(ToolStatusEnd(name: name, message: message));
  }

  void setCurrentWorkingDirectory(String path) {
    currentWorkingDirectory = _normalizeDirectoryPath(path);
  }

  String resolvePath(
    String path, {
    String? fromDirectory,
  }) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) {
      return File(fromDirectory ?? currentWorkingDirectory).absolute.path;
    }
    if (_isAbsolutePath(trimmed)) {
      return File(trimmed).absolute.path;
    }

    final base = Directory(fromDirectory ?? currentWorkingDirectory).absolute.path;
    return File('$base${Platform.pathSeparator}$trimmed').absolute.path;
  }

  String resolveDirectory(
    String path, {
    String? fromDirectory,
  }) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) {
      return Directory(fromDirectory ?? currentWorkingDirectory).absolute.path;
    }
    if (_isAbsolutePath(trimmed)) {
      return Directory(trimmed).absolute.path;
    }

    final base = Directory(fromDirectory ?? currentWorkingDirectory).absolute.path;
    return Directory('$base${Platform.pathSeparator}$trimmed').absolute.path;
  }

  bool isWithinWorkspace(String path) {
    final absolute = File(path).absolute.path;
    final normalizedRoot = Directory(workspaceRoot).absolute.path;
    return absolute == normalizedRoot || absolute.startsWith('$normalizedRoot${Platform.pathSeparator}');
  }

  void recordFileRead(String path, String content, FileStat stat) {
    _trackedFiles[File(path).absolute.path] = TrackedFileState(
      path: File(path).absolute.path,
      content: content,
      lastModified: stat.modified,
      size: stat.size,
    );
  }

  TrackedFileState? trackedFile(String path) {
    return _trackedFiles[File(path).absolute.path];
  }

  Future<bool> fileMatchesTrackedState(String path) async {
    final tracked = trackedFile(path);
    if (tracked == null) {
      return false;
    }

    final file = File(path);
    if (!await file.exists()) {
      return false;
    }

    final stat = await file.stat();
    if (stat.modified != tracked.lastModified || stat.size != tracked.size) {
      return false;
    }

    final content = await file.readAsString();
    return content == tracked.content;
  }

  Future<String> readTrackedCurrentContent(String path) async {
    final file = File(path);
    final content = await file.readAsString();
    final stat = await file.stat();
    recordFileRead(path, content, stat);
    return content;
  }

  SessionTask createTask({
    required String subject,
    required String description,
    String? activeForm,
    Map<String, dynamic>? metadata,
  }) {
    final task = SessionTask(
      id: '${_nextTaskId++}',
      subject: subject,
      description: description,
      activeForm: activeForm,
      status: SessionTaskStatus.pending,
      metadata: metadata,
    );
    _tasks[task.id] = task;
    return task;
  }

  SessionTask? taskById(String id) => _tasks[id];

  List<SessionTask> listTasks() {
    final tasks = _tasks.values.toList()..sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
    return tasks;
  }

  String? validateTaskTransition({
    required String taskId,
    SessionTaskStatus? newStatus,
  }) {
    if (newStatus != SessionTaskStatus.inProgress) {
      return null;
    }

    for (final task in _tasks.values) {
      if (task.id != taskId && task.status == SessionTaskStatus.inProgress) {
        return 'Task #${task.id} is already in_progress. Complete it or move it out of progress first.';
      }
    }
    return null;
  }

  static String _normalizeDirectoryPath(String path) {
    return Directory(path).absolute.path;
  }

  static bool _isAbsolutePath(String path) {
    return path.startsWith('/') || RegExp(r'^[A-Za-z]:[\\/]').hasMatch(path);
  }
}
