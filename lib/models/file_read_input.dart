import 'package:schemantic/schemantic.dart';

part 'file_read_input.g.dart';

@Schema(description: 'The input for the file read tool.')
/// Schema-backed input passed to the file-read tool.
abstract class $FileReadInput {
  @StringField(description: 'The path to the file to read.')
  /// The path of the file to read.
  String get path;
}
