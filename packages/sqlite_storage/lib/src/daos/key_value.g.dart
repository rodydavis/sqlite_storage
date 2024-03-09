// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key_value.dart';

// ignore_for_file: type=lint
mixin _$KeyValueDaoMixin on DatabaseAccessor<DriftStorage> {
  KeyValue get keyValue => attachedDatabase.keyValue;
  Documents get documents => attachedDatabase.documents;
  Analytics get analytics => attachedDatabase.analytics;
  Files get files => attachedDatabase.files;
  Nodes get nodes => attachedDatabase.nodes;
  Edges get edges => attachedDatabase.edges;
  Logging get logging => attachedDatabase.logging;
  Requests get requests => attachedDatabase.requests;
  OfflineRequestQueue get offlineRequestQueue =>
      attachedDatabase.offlineRequestQueue;
  OfflineRequestQueueFiles get offlineRequestQueueFiles =>
      attachedDatabase.offlineRequestQueueFiles;
  Selectable<KeyValueData> _search(String query) {
    return customSelect(
        'SELECT "key", value FROM key_value WHERE "key" LIKE ?1 OR value LIKE ?1',
        variables: [
          Variable<String>(query)
        ],
        readsFrom: {
          keyValue,
        }).asyncMap(keyValue.mapFromRow);
  }

  Future<int> _delete(String key) {
    return customUpdate(
      'DELETE FROM key_value WHERE "key" = ?1',
      variables: [Variable<String>(key)],
      updates: {keyValue},
      updateKind: UpdateKind.delete,
    );
  }

  Future<int> _deleteWhere(List<String> keys) {
    var $arrayStartIndex = 1;
    final expandedkeys = $expandVar($arrayStartIndex, keys.length);
    $arrayStartIndex += keys.length;
    return customUpdate(
      'DELETE FROM key_value WHERE "key" IN ($expandedkeys)',
      variables: [for (var $ in keys) Variable<String>($)],
      updates: {keyValue},
      updateKind: UpdateKind.delete,
    );
  }

  Future<int> _deleteAll() {
    return customUpdate(
      'DELETE FROM key_value',
      variables: [],
      updates: {keyValue},
      updateKind: UpdateKind.delete,
    );
  }

  Future<List<KeyValueData>> _set(String key, DriftAny? value) {
    return customWriteReturning(
        'INSERT OR REPLACE INTO key_value ("key", value) VALUES (?1, ?2) RETURNING *',
        variables: [
          Variable<String>(key),
          Variable<DriftAny>(value)
        ],
        updates: {
          keyValue
        }).then((rows) => Future.wait(rows.map(keyValue.mapFromRow)));
  }

  Selectable<DriftAny?> _get(String key) {
    return customSelect('SELECT value FROM key_value WHERE "key" = ?1',
        variables: [
          Variable<String>(key)
        ],
        readsFrom: {
          keyValue,
        }).map((QueryRow row) => row.readNullable<DriftAny>('value'));
  }

  Selectable<KeyValueData> _getAll() {
    return customSelect('SELECT "key", value FROM key_value',
        variables: [],
        readsFrom: {
          keyValue,
        }).asyncMap(keyValue.mapFromRow);
  }

  Selectable<KeyValueData> _getAllFilter(List<String> keys) {
    var $arrayStartIndex = 1;
    final expandedkeys = $expandVar($arrayStartIndex, keys.length);
    $arrayStartIndex += keys.length;
    return customSelect(
        'SELECT "key", value FROM key_value WHERE "key" IN ($expandedkeys)',
        variables: [
          for (var $ in keys) Variable<String>($)
        ],
        readsFrom: {
          keyValue,
        }).asyncMap(keyValue.mapFromRow);
  }
}
