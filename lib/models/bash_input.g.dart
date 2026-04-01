// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bash_input.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

base class BashInput {
  factory BashInput.fromJson(Map<String, dynamic> json) => $schema.parse(json);

  BashInput._(this._json);

  BashInput({required String command}) {
    _json = {'command': command};
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<BashInput> $schema = _BashInputTypeFactory();

  String get command {
    return _json['command'] as String;
  }

  set command(String value) {
    _json['command'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _BashInputTypeFactory extends SchemanticType<BashInput> {
  const _BashInputTypeFactory();

  @override
  BashInput parse(Object? json) {
    return BashInput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'BashInput',
    definition: $Schema
        .object(
          properties: {
            'command': $Schema.string(description: 'The command to execute.'),
          },
          required: ['command'],
          description: 'The input for the bash tool.',
        )
        .value,
    dependencies: [],
  );
}
