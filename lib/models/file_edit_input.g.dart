// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_edit_input.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

base class FileEditInput {
  factory FileEditInput.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  FileEditInput._(this._json);

  FileEditInput({required String path, required String sedCommand}) {
    _json = {'path': path, 'sedCommand': sedCommand};
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<FileEditInput> $schema =
      _FileEditInputTypeFactory();

  String get path {
    return _json['path'] as String;
  }

  set path(String value) {
    _json['path'] = value;
  }

  String get sedCommand {
    return _json['sedCommand'] as String;
  }

  set sedCommand(String value) {
    _json['sedCommand'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _FileEditInputTypeFactory extends SchemanticType<FileEditInput> {
  const _FileEditInputTypeFactory();

  @override
  FileEditInput parse(Object? json) {
    return FileEditInput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'FileEditInput',
    definition: $Schema
        .object(
          properties: {
            'path': $Schema.string(
              description: 'The path to the file to edit.',
            ),
            'sedCommand': $Schema.string(
              description:
                  'The sed script or command to run on the file (e.g., s/foo/bar/g, or any valid sed program).',
            ),
          },
          required: ['path', 'sedCommand'],
          description:
              'The input for the file edit tool supporting all sed command features.',
        )
        .value,
    dependencies: [],
  );
}
