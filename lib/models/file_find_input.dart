import 'package:schemantic/schemantic.dart';

part 'file_find_input.g.dart';

@Schema(description: 'The input for the file find tool.')
/// Schema-backed input passed to the file-find tool.
abstract class $FileFindInput {
  @StringField(description: 'The query to find.')
  /// The file name pattern to search for.
  String get query;
}
