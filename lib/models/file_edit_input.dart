import 'package:schemantic/schemantic.dart';

part 'file_edit_input.g.dart';

@Schema(description: 'The input for the file edit tool supporting all sed command features.')
/// Schema-backed input passed to the file edit tool, supports any sed command.
abstract class $FileEditInput {
  @StringField(description: 'The path to the file to edit.')
  /// The path to the file to edit.
  String get path;

  @StringField(
    description: 'The sed script or command to run on the file (e.g., s/foo/bar/g, or any valid sed program).',
  )
  /// The sed script to execute.
  String get sedCommand;
}
