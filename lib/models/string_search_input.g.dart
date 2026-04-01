// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'string_search_input.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

base class StringSearchInput {
  factory StringSearchInput.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  StringSearchInput._(this._json);

  StringSearchInput({required String query}) {
    _json = {'query': query};
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<StringSearchInput> $schema =
      _StringSearchInputTypeFactory();

  String get query {
    return _json['query'] as String;
  }

  set query(String value) {
    _json['query'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _StringSearchInputTypeFactory
    extends SchemanticType<StringSearchInput> {
  const _StringSearchInputTypeFactory();

  @override
  StringSearchInput parse(Object? json) {
    return StringSearchInput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'StringSearchInput',
    definition: $Schema
        .object(
          properties: {
            'query': $Schema.string(description: 'The query to search for.'),
          },
          required: ['query'],
          description: 'The input for the string search tool.',
        )
        .value,
    dependencies: [],
  );
}
