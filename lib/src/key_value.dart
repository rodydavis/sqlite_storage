import 'dart:convert';

import 'package:sqlite_async/sqlite_async.dart';

import 'database/database.dart';

class KeyValueDatabase extends Dao {
  KeyValueDatabase(super.database);

  @override
  Future<void> migrate(int toVersion, SqliteWriteContext tx, bool down) async {
    if (toVersion == 1) {
      if (down) {
        await tx.execute('DROP TABLE key_value');
      } else {
        await tx.execute(_createSql);
      }
    }
  }

  Future<List<Map<String, Object?>>> search(String query) async {
    final result = await database.db.getAll(
      'SELECT key, value FROM key_value WHERE key LIKE :q OR value LIKE :q',
      ['$query%'],
    );
    final items = result.map(
      (row) => Map<String, Object?>.fromEntries(
        row.entries.map(
          (e) => MapEntry(e.key, e.value),
        ),
      ),
    );
    return items.toList();
  }

  Future<void> remove(String key) async {
    await database.db.execute(
      'DELETE FROM key_value WHERE key = ?',
      [key],
    );
  }

  Future<void> removeAll(List<String> keys) async {
    await database.db.writeTransaction((tx) async {
      for (var key in keys) {
        await tx.execute(
          'DELETE FROM key_value WHERE key = ?',
          [key],
        );
      }
    });
  }

  Future<void> set(String key, dynamic value) async {
    await database.db.execute(
      'INSERT OR REPLACE INTO key_value (key, value) VALUES (?, ?)',
      [key, value],
    );
  }

  Future<void> setAll(Map<String, Object?> values) async {
    await database.db.writeTransaction((tx) async {
      for (var entry in values.entries) {
        await tx.execute(
          'INSERT OR REPLACE INTO key_value (key, value) VALUES (?, ?)',
          [entry.key, entry.value],
        );
      }
    });
  }

  Future<Object?> get(String key) async {
    final result = await database.db.getOptional(
      'SELECT value FROM key_value WHERE key = ?',
      [key],
    );
    if (result == null) return null;
    return result['value'];
  }

  Stream<Object?> watch(
    String key, {
    Duration throttle = const Duration(milliseconds: 30),
  }) {
    return database.db
        .watch(
          'SELECT value FROM key_value WHERE key = ?',
          parameters: [key],
          throttle: throttle,
        )
        .map((row) => row.isEmpty ? null : row.first['value']);
  }

  Future<Map<String, Object?>> getAll() async {
    final result = await database.db.getAll('SELECT * FROM key_value');
    return Map<String, Object?>.fromEntries(result.map(
      (row) => MapEntry(
        row['key'] as String,
        row['value'],
      ),
    ));
  }

  Stream<Map<String, Object?>> watchAll({
    Duration throttle = const Duration(milliseconds: 30),
    List<String> keys = const [],
  }) {
    final sql = StringBuffer('SELECT * FROM key_value');
    if (keys.isNotEmpty) {
      sql.write(' WHERE key IN (');
      sql.writeAll(keys.map((e) => '?'), ',');
      sql.write(')');
    }
    return database.db
        .watch(sql.toString(), throttle: throttle, parameters: keys)
        .map((row) => Map<String, Object?>.fromEntries(
              row.map(
                (e) => MapEntry(e['key'] as String, e['value']),
              ),
            ));
  }

  Future<void> clear() async {
    await database.db.execute('DELETE FROM key_value');
  }

  Future<String?> getString(String key) async {
    final result = await get(key);
    if (result == null) return null;
    if (result is String) return result;
    throw Exception(
        'Value for key "$key" is not a string (${result.runtimeType}|$result)');
  }

  Stream<String?> watchString(
    String key, {
    Duration throttle = const Duration(milliseconds: 30),
  }) {
    return watch(key, throttle: throttle).map((value) {
      if (value == null) return null;
      if (value is String) return value;
      throw Exception('Value for key "$key" is not a string');
    });
  }

  Future<void> setString(String key, String value) async {
    await set(key, value);
  }

  Future<int?> getInt(String key) async {
    final result = await get(key);
    if (result == null) return null;
    if (result is int) return result;
    throw Exception('Value for key "$key" is not an int');
  }

  Stream<int?> watchInt(
    String key, {
    Duration throttle = const Duration(milliseconds: 30),
  }) {
    return watch(key, throttle: throttle).map((value) {
      if (value == null) return null;
      if (value is int) return value;
      throw Exception('Value for key "$key" is not an int');
    });
  }

  Future<void> setInt(String key, int value) async {
    await set(key, value);
  }

  Future<double?> getDouble(String key) async {
    final result = await get(key);
    if (result == null) return null;
    if (result is num) return result.toDouble();
    throw Exception('Value for key "$key" is not a double');
  }

  Stream<double?> watchDouble(
    String key, {
    Duration throttle = const Duration(milliseconds: 30),
  }) {
    return watch(key, throttle: throttle).map((value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      throw Exception('Value for key "$key" is not a double');
    });
  }

  Future<void> setDouble(String key, double value) async {
    await set(key, value);
  }

  Future<void> setNum(String key, num value) async {
    await set(key, value);
  }

  Future<num?> getNum(String key) async {
    final result = await get(key);
    if (result == null) return null;
    if (result is num) return result;
    throw Exception('Value for key "$key" is not a num');
  }

  Stream<num?> watchNum(
    String key, {
    Duration throttle = const Duration(milliseconds: 30),
  }) {
    return watch(key, throttle: throttle).map((value) {
      if (value == null) return null;
      if (value is num) return value;
      throw Exception('Value for key "$key" is not a num');
    });
  }

  Future<void> setBool(String key, bool value) async {
    await set(key, value ? 1 : 0);
  }

  Future<bool?> getBool(String key) async {
    final result = await get(key);
    if (result == null) return null;
    if (result is int) return result != 0;
    throw Exception('Value for key "$key" is not a bool');
  }

  Stream<bool?> watchBool(
    String key, {
    Duration throttle = const Duration(milliseconds: 30),
  }) {
    return watch(key, throttle: throttle).map((value) {
      if (value == null) return null;
      if (value is int) return value != 0;
      throw Exception('Value for key "$key" is not a bool');
    });
  }

  Future<void> setJsonMap(String key, Map<String, Object?> value) async {
    await set(key, jsonEncode(value));
  }

  Future<Map<String, Object?>?> getJsonMap(String key) async {
    final result = await get(key);
    if (result == null) return null;
    if (result is String) return jsonDecode(result) as Map<String, Object?>;
    throw Exception('Value for key "$key" is not a Map<String, Object?>');
  }

  Stream<Map<String, Object?>?> watchJsonMap(
    String key, {
    Duration throttle = const Duration(milliseconds: 30),
  }) {
    return watch(key, throttle: throttle).map((value) {
      if (value == null) return null;
      if (value is String) return jsonDecode(value) as Map<String, Object?>;
      throw Exception('Value for key "$key" is not a Map<String, Object?>');
    });
  }

  Future<void> setJsonList(String key, List<Object?> value) async {
    await set(key, jsonEncode(value));
  }

  Future<List<Object?>?> getJsonList(String key) async {
    final result = await get(key);
    if (result == null) return null;
    if (result is String) return jsonDecode(result) as List<Object?>;
    throw Exception('Value for key "$key" is not a List<Object?>');
  }

  Stream<List<Object?>?> watchJsonList(
    String key, {
    Duration throttle = const Duration(milliseconds: 30),
  }) {
    return watch(key, throttle: throttle).map((value) {
      if (value == null) return null;
      if (value is String) return jsonDecode(value) as List<Object?>;
      throw Exception('Value for key "$key" is not a List<Object?>');
    });
  }

  Future<void> setJson(String key, Object? value) async {
    await set(key, jsonEncode(value));
  }

  Future<Object?> getJson(String key) async {
    final result = await get(key);
    if (result == null) return null;
    if (result is String) return jsonDecode(result);
    throw Exception('Value for key "$key" is not a JSON object');
  }

  Stream<Object?> watchJson(
    String key, {
    Duration throttle = const Duration(milliseconds: 30),
  }) {
    return watch(key, throttle: throttle).map((value) {
      if (value == null) return null;
      if (value is String) return jsonDecode(value);
      throw Exception('Value for key "$key" is not a JSON object');
    });
  }

  Future<void> setBytes(String key, List<int> value) async {
    await set(key, value);
  }

  Future<List<int>?> getBytes(String key) async {
    final result = await get(key);
    if (result == null) return null;
    if (result is List<int>) return result;
    throw Exception('Value for key "$key" is not a List<int>');
  }

  Stream<List<int>?> watchBytes(
    String key, {
    Duration throttle = const Duration(milliseconds: 30),
  }) {
    return watch(key, throttle: throttle).map((value) {
      if (value == null) return null;
      if (value is List<int>) return value;
      throw Exception('Value for key "$key" is not a List<int>');
    });
  }

  Future<void> setStringList(String key, List<String> value) async {
    await set(key, jsonEncode(value));
  }

  Future<List<String>?> getStringList(String key) async {
    final result = await get(key);
    if (result == null) return null;
    if (result is String) return (jsonDecode(result) as List).cast<String>();
    throw Exception('Value for key "$key" is not a List<String>');
  }

  Stream<List<String>?> watchStringList(
    String key, {
    Duration throttle = const Duration(milliseconds: 30),
  }) {
    return watch(key, throttle: throttle).map((value) {
      if (value == null) return null;
      if (value is String) return (jsonDecode(value) as List).cast<String>();
      throw Exception('Value for key "$key" is not a List<String>');
    });
  }

  Future<void> setEnum<T extends Enum>(String key, T value) {
    return setString(key, value.name);
  }

  Future<T?> getEnum<T extends Enum>(List<T> values, String key) async {
    final name = await getString(key);
    if (name == null) return null;
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw Exception('Value for key "$key" is not a valid enum'),
    );
  }

  Stream<T?> watchEnum<T extends Enum>(
    List<T> values,
    String key, {
    Duration throttle = const Duration(milliseconds: 30),
  }) {
    return watchString(key, throttle: throttle).map((name) {
      if (name == null) return null;
      return values.firstWhere(
        (e) => e.name == name,
        orElse: () =>
            throw Exception('Value for key "$key" is not a valid enum'),
      );
    });
  }

  Future<void> setDateTime(String key, DateTime value) async {
    await setString(key, value.toIso8601String());
  }

  Future<DateTime?> getDateTime(String key) async {
    final result = await getString(key);
    if (result == null) return null;
    return DateTime.parse(result);
  }

  Stream<DateTime?> watchDateTime(
    String key, {
    Duration throttle = const Duration(milliseconds: 30),
  }) {
    return watchString(key, throttle: throttle).map((value) {
      if (value == null) return null;
      return DateTime.parse(value);
    });
  }

  Future<void> setDuration(String key, Duration value) async {
    await setInt(key, value.inMilliseconds);
  }

  Future<Duration?> getDuration(String key) async {
    final result = await getInt(key);
    if (result == null) return null;
    return Duration(milliseconds: result);
  }

  Stream<Duration?> watchDuration(
    String key, {
    Duration throttle = const Duration(milliseconds: 30),
  }) {
    return watchInt(key, throttle: throttle).map((value) {
      if (value == null) return null;
      return Duration(milliseconds: value);
    });
  }
}

const _createSql = '''
CREATE TABLE key_value (
  key TEXT PRIMARY KEY,
  value,
  UNIQUE(key)
);
''';
