import 'dart:convert';

import 'package:drift/drift.dart';

import '../database.dart';

part 'key_value.g.dart';

@DriftAccessor(include: {'../sql/key_value.drift'})
class KeyValueDao extends DatabaseAccessor<DriftStorage>
    with _$KeyValueDaoMixin {
  KeyValueDao(super.db);

  Future<void> remove(String key) => _delete(key);

  Future<void> removeAll(List<String> keys) => _deleteWhere(keys);

  Future<void> set(String key, Object? value) => _set(
        key,
        value == null ? null : DriftAny(value),
      );

  Future<void> setAll(Map<String, Object?> values) async {
    await db.batch((tx) {
      tx.insertAll(
        db.keyValue,
        [
          for (final item in values.entries)
            KeyValueCompanion.insert(
              key: item.key,
              value: item.value == null
                  ? const Value.absent()
                  : Value(DriftAny(item.value!)),
            ),
        ],
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Selectable<MapEntry<String, Object?>> search(String query) {
    return _search(query).map((e) => MapEntry(e.key, e.value?.rawSqlValue));
  }

  Future<Object?> get(String key) =>
      _get(key).map((e) => e?.rawSqlValue).getSingleOrNull();

  Stream<Object?> watch(String key) =>
      _get(key).map((e) => e?.rawSqlValue).watchSingleOrNull();

  Future<Map<String, Object?>> getAll({List<String> keys = const []}) {
    if (keys.isEmpty) {
      return _getAll().get().then((value) => {
            for (final item in value) ...{item.key: item.value?.rawSqlValue},
          });
    } else {
      return _getAllFilter(keys).get().then((value) => {
            for (final item in value) ...{item.key: item.value?.rawSqlValue},
          });
    }
  }

  Stream<Map<String, Object?>> watchAll({List<String> keys = const []}) {
    if (keys.isEmpty) {
      return _getAll().watch().map((value) => {
            for (final item in value) ...{item.key: item.value?.rawSqlValue},
          });
    } else {
      return _getAllFilter(keys).watch().map((value) => {
            for (final item in value) ...{item.key: item.value?.rawSqlValue},
          });
    }
  }

  Future<void> clear({
    List<String> keys = const [],
  }) {
    if (keys.isEmpty) {
      return _deleteAll();
    } else {
      return _deleteWhere(keys);
    }
  }

  late final $bool = KeyValueContainer<int, bool>(
    this,
    read: (val) => val != 0,
    save: (val) => val != null
        ? val
            ? 1
            : 0
        : null,
  );

  late final $jsonMap = KeyValueContainer<String, Map<String, Object?>>(
    this,
    read: (val) => jsonDecode(val) as Map<String, Object?>? ?? {},
    save: (val) => jsonEncode(val),
  );

  late final $jsonList = KeyValueContainer<String, List<Object?>>(
    this,
    read: (val) => jsonDecode(val) as List<Object?>? ?? [],
    save: (val) => jsonEncode(val),
  );

  late final $json = KeyValueContainer<String, Object>(
    this,
    read: (val) => jsonDecode(val),
    save: (val) => jsonEncode(val),
  );

  late final $bytes = KeyValueContainer<List<int>, List<int>>(
    this,
    read: (val) => val,
    save: (val) => val,
  );

  KeyValueContainer<String, T> $enum<T extends Enum>(List<T> values) {
    return KeyValueContainer<String, T>(
      this,
      read: (val) => values.firstWhere(
        (e) => e.name == val,
        orElse: () {
          throw Exception('Value "$val" is not a valid enum');
        },
      ),
      save: (val) => val?.name,
    );
  }

  late final $stringList = KeyValueContainer<String, List<String>>(
    this,
    read: (val) => (jsonDecode(val) as List).cast<String>(),
    save: (val) => jsonEncode(val),
  );

  late final $duration = KeyValueContainer<int, Duration>(
    this,
    read: (val) => Duration(milliseconds: val),
    save: (val) => val?.inMilliseconds,
  );

  late final $dateTime = KeyValueContainer<int, DateTime>(
    this,
    read: (val) => DateTime.fromMillisecondsSinceEpoch(val),
    save: (val) => val?.millisecondsSinceEpoch,
  );

  late final $dateTimeIso8601 = KeyValueContainer<String, DateTime>(
    this,
    read: (val) => DateTime.tryParse(val),
    save: (val) => val?.toIso8601String(),
  );

  late final $string = KeyValueContainer<String, String>(
    this,
    read: (val) => val,
    save: (val) => val,
  );

  late final $int = KeyValueContainer<num, int>(
    this,
    read: (val) => val.toInt(),
    save: (val) => val,
  );

  late final $double = KeyValueContainer<num, double>(
    this,
    read: (val) => val.toDouble(),
    save: (val) => val,
  );

  late final $num = KeyValueContainer<num, num>(
    this,
    read: (val) => val,
    save: (val) => val,
  );
}

class KeyValueContainer<RawType, T> {
  final KeyValueDao db;

  final T? Function(RawType) read;
  final RawType? Function(T?) save;

  KeyValueContainer(
    this.db, {
    required this.read,
    required this.save,
  });

  Selectable<T?> select(String key) {
    return db._get(key).map((e) => e?.rawSqlValue).map((result) {
      if (result == null) return null;
      if (result is RawType) return read(result as RawType);
      throw Exception(
        'Value for key "$key" is not a $RawType (${result.runtimeType}|$result)',
      );
    });
  }

  Future<T?> get(String key) => select(key).getSingleOrNull();

  Stream<T?> watch(String key) => select(key).watchSingleOrNull();

  Future<void> set(String key, T? value) {
    return db.set(key, save(value));
  }
}
