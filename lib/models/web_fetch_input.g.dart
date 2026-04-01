// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_fetch_input.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

base class WebFetchInput {
  factory WebFetchInput.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  WebFetchInput._(this._json);

  WebFetchInput({required String url}) {
    _json = {'url': url};
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<WebFetchInput> $schema =
      _WebFetchInputTypeFactory();

  String get url {
    return _json['url'] as String;
  }

  set url(String value) {
    _json['url'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _WebFetchInputTypeFactory extends SchemanticType<WebFetchInput> {
  const _WebFetchInputTypeFactory();

  @override
  WebFetchInput parse(Object? json) {
    return WebFetchInput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'WebFetchInput',
    definition: $Schema
        .object(
          properties: {'url': $Schema.string(description: 'The URL to fetch.')},
          required: ['url'],
          description: 'The input for the web fetch tool.',
        )
        .value,
    dependencies: [],
  );
}
