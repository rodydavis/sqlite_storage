import 'dart:convert';

import 'package:drift/drift.dart';

class JsonStringListConverter extends TypeConverter<List<String>, String> {
  const JsonStringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    try {
      final val = json.decode(fromDb);
      return List<String>.from(val);
    } catch (e) {
      return [];
    }
  }

  @override
  String toSql(List<String> value) {
    return json.encode(value);
  }
}

class JsonMapConverter extends TypeConverter<Map<String, dynamic>, String> {
  const JsonMapConverter();

  @override
  Map<String, dynamic> fromSql(String fromDb) {
    final val = json.decode(fromDb);
    return Map<String, dynamic>.from(val);
  }

  @override
  String toSql(Map<String, dynamic> value) {
    return json.encode(value);
  }
}
