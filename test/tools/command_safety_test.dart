import 'package:lea_code/tools/utils/command_safety.dart';
import 'package:test/test.dart';

void main() {
  group('assessBashCommand', () {
    test('allows common read-only commands without approval', () {
      final assessment = assessBashCommand('git status');

      expect(assessment.requiresApproval, isFalse);
      expect(assessment.reason, isNull);
    });

    test('requires approval for mutating commands', () {
      final assessment = assessBashCommand('git commit -m "test"');

      expect(assessment.requiresApproval, isTrue);
      expect(
        assessment.reason,
        'This command may modify files or repository state.',
      );
    });

    test('requires approval for network commands', () {
      final assessment = assessBashCommand('curl https://example.com');

      expect(assessment.requiresApproval, isTrue);
      expect(assessment.reason, 'This command may access the network.');
    });
  });
}
