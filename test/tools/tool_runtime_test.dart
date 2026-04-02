import 'dart:io';

import 'package:lea_code/tools/models/session_task.dart';
import 'package:lea_code/tools/runtime/tool_runtime.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late ToolRuntime runtime;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('lea_code_runtime_test');
    runtime = ToolRuntime(
      onMessage: (_) {},
      requestApproval: (_) async => true,
      askQuestions: (_) async => <String, String>{},
      workspaceRoot: tempDir.path,
      currentWorkingDirectory: tempDir.path,
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('tracks file reads and detects unchanged content', () async {
    final file = File('${tempDir.path}/sample.txt');
    await file.writeAsString('hello');
    runtime.recordFileRead(file.path, 'hello', await file.stat());

    expect(await runtime.fileMatchesTrackedState(file.path), isTrue);

    await file.writeAsString('goodbye');
    expect(await runtime.fileMatchesTrackedState(file.path), isFalse);
  });

  test('creates ordered tasks and enforces one in-progress task', () {
    final first = runtime.createTask(
      subject: 'First',
      description: 'First task',
    );
    final second = runtime.createTask(
      subject: 'Second',
      description: 'Second task',
    );

    first.status = SessionTaskStatus.inProgress;

    expect(
      runtime.validateTaskTransition(
        taskId: second.id,
        newStatus: SessionTaskStatus.inProgress,
      ),
      contains(first.id),
    );

    expect(runtime.listTasks().map((task) => task.id), <String>[
      first.id,
      second.id,
    ]);
  });

  test('resolves relative paths from the current working directory', () {
    final resolved = runtime.resolvePath('nested/file.txt');

    expect(
      resolved,
      File('${tempDir.path}/nested/file.txt').absolute.path,
    );
  });
}
