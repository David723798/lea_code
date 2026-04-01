import 'package:schemantic/schemantic.dart';

part 'web_fetch_input.g.dart';

@Schema(description: 'The input for the web fetch tool.')
/// Schema-backed input passed to the web-fetch tool.
abstract class $WebFetchInput {
  @StringField(description: 'The URL to fetch.')
  /// The URL to fetch.
  String get url;
}
