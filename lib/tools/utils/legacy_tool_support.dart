import 'package:schemantic/schemantic.dart';

typedef JsonMap = Map<String, dynamic>;

JsonMap parseJsonMap(Object? json) {
  if (json == null) {
    return <String, dynamic>{};
  }
  if (json is Map) {
    return json.map((key, value) => MapEntry('$key', value));
  }
  throw ArgumentError('Expected a JSON object but received ${json.runtimeType}.');
}

SchemanticType<JsonMap> createJsonObjectSchema({
  String? description,
  Map<String, $Schema> properties = const <String, $Schema>{},
  List<String> required = const <String>[],
}) {
  final schema = $Schema
      .object(
        properties: properties,
        required: required,
        additionalProperties: $Schema.any(),
      )
      .value;

  return SchemanticType.from<JsonMap>(
    jsonSchema: {
      ...schema,
      'description': description,
    },
    parse: parseJsonMap,
  );
}

SchemanticType<String> get stringOutputSchema => SchemanticType.string();

SchemanticType<JsonMap> createJsonSchema(
  Map<String, dynamic> schema,
) {
  return SchemanticType.from<JsonMap>(
    jsonSchema: schema,
    parse: parseJsonMap,
  );
}

String? readString(JsonMap input, String key) {
  final value = input[key];
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value;
  }
  return '$value';
}

int? readInt(JsonMap input, String key) {
  final value = input[key];
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse('$value');
}

bool? readBool(JsonMap input, String key) {
  final value = input[key];
  if (value == null) {
    return null;
  }
  if (value is bool) {
    return value;
  }
  final normalized = '$value'.trim().toLowerCase();
  if (normalized == 'true') {
    return true;
  }
  if (normalized == 'false') {
    return false;
  }
  return null;
}

JsonMap? readJsonMap(JsonMap input, String key) {
  final value = input[key];
  if (value == null) {
    return null;
  }
  if (value is Map) {
    return value.map((mapKey, mapValue) => MapEntry('$mapKey', mapValue));
  }
  return null;
}

List<dynamic>? readList(JsonMap input, String key) {
  final value = input[key];
  if (value == null) {
    return null;
  }
  if (value is List) {
    return value;
  }
  return null;
}
