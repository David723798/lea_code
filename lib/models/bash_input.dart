import 'package:schemantic/schemantic.dart';

part 'bash_input.g.dart';

@Schema(description: 'The input for the bash tool.')
/// Schema-backed input passed to the bash tool.
abstract class $BashInput {
  @StringField(description: 'The command to execute.')
  /// The shell command to execute.
  String get command;
}
