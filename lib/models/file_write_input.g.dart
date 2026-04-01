// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_write_input.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

base class FileWriteInput {
  factory FileWriteInput.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  FileWriteInput._(this._json);

  FileWriteInput({required String path, required String content}) {
    _json = {'path': path, 'content': content};
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<FileWriteInput> $schema =
      _FileWriteInputTypeFactory();

  String get path {
    return _json['path'] as String;
  }

  set path(String value) {
    _json['path'] = value;
  }

  String get content {
    return _json['content'] as String;
  }

  set content(String value) {
    _json['content'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _FileWriteInputTypeFactory extends SchemanticType<FileWriteInput> {
  const _FileWriteInputTypeFactory();

  @override
  FileWriteInput parse(Object? json) {
    return FileWriteInput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'FileWriteInput',
    definition: $Schema
        .object(
          properties: {
            'path': $Schema.string(
              description: 'The path to the file to write.',
            ),
            'content': $Schema.string(
              description: 'The content to write to the file.',
            ),
          },
          required: ['path', 'content'],
          description: 'The input for the file write tool.',
        )
        .value,
    dependencies: [],
  );
}
