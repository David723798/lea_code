import 'package:schemantic/schemantic.dart';

part 'string_search_input.g.dart';

@Schema(description: 'The input for the string search tool.')
/// Schema-backed input passed to the string-search tool.
abstract class $StringSearchInput {
  @StringField(description: 'The query to search for.')
  /// The text pattern to search for.
  String get query;
}
