// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_read_input.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

base class FileReadInput {
  factory FileReadInput.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  FileReadInput._(this._json);

  FileReadInput({required String path}) {
    _json = {'path': path};
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<FileReadInput> $schema =
      _FileReadInputTypeFactory();

  String get path {
    return _json['path'] as String;
  }

  set path(String value) {
    _json['path'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _FileReadInputTypeFactory extends SchemanticType<FileReadInput> {
  const _FileReadInputTypeFactory();

  @override
  FileReadInput parse(Object? json) {
    return FileReadInput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'FileReadInput',
    definition: $Schema
        .object(
          properties: {
            'path': $Schema.string(
              description: 'The path to the file to read.',
            ),
          },
          required: ['path'],
          description: 'The input for the file read tool.',
        )
        .value,
    dependencies: [],
  );
}
