import 'package:schemantic/schemantic.dart';

part 'file_write_input.g.dart';

@Schema(description: 'The input for the file write tool.')
/// Schema-backed input passed to the file-write tool.
abstract class $FileWriteInput {
  @StringField(description: 'The path to the file to write.')
  /// The path of the file to write.
  String get path;

  @StringField(description: 'The content to write to the file.')
  /// The content to write to [path].
  String get content;
}
