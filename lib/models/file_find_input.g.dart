// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_find_input.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

base class FileFindInput {
  factory FileFindInput.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  FileFindInput._(this._json);

  FileFindInput({required String query}) {
    _json = {'query': query};
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<FileFindInput> $schema =
      _FileFindInputTypeFactory();

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

base class _FileFindInputTypeFactory extends SchemanticType<FileFindInput> {
  const _FileFindInputTypeFactory();

  @override
  FileFindInput parse(Object? json) {
    return FileFindInput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'FileFindInput',
    definition: $Schema
        .object(
          properties: {
            'query': $Schema.string(description: 'The query to find.'),
          },
          required: ['query'],
          description: 'The input for the file find tool.',
        )
        .value,
    dependencies: [],
  );
}
