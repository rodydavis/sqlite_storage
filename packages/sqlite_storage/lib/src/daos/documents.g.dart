// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'documents.dart';

// ignore_for_file: type=lint
mixin _$DocumentsDaoMixin on DatabaseAccessor<DriftStorage> {
  Documents get documents => attachedDatabase.documents;
  KeyValue get keyValue => attachedDatabase.keyValue;
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
  Selectable<Doc> _search(String query) {
    return customSelect(
        'SELECT * FROM documents WHERE(path LIKE ?1 OR data LIKE ?1)AND((ttl IS NOT NULL AND ttl + updated < unixepoch())OR ttl IS NULL)',
        variables: [
          Variable<String>(query)
        ],
        readsFrom: {
          documents,
        }).asyncMap(documents.mapFromRow);
  }

  Selectable<Doc> _filter(String query) {
    return customSelect(
        'SELECT * FROM documents WHERE path LIKE ?1 AND((ttl IS NOT NULL AND ttl + updated < unixepoch())OR ttl IS NULL)',
        variables: [
          Variable<String>(query)
        ],
        readsFrom: {
          documents,
        }).asyncMap(documents.mapFromRow);
  }

  Future<int> _delete(String path) {
    return customUpdate(
      'DELETE FROM documents WHERE path = ?1',
      variables: [Variable<String>(path)],
      updates: {documents},
      updateKind: UpdateKind.delete,
    );
  }

  Future<int> _deleteWhere(List<String> paths) {
    var $arrayStartIndex = 1;
    final expandedpaths = $expandVar($arrayStartIndex, paths.length);
    $arrayStartIndex += paths.length;
    return customUpdate(
      'DELETE FROM documents WHERE path IN ($expandedpaths)',
      variables: [for (var $ in paths) Variable<String>($)],
      updates: {documents},
      updateKind: UpdateKind.delete,
    );
  }

  Future<int> _deleteFilter(String path) {
    return customUpdate(
      'DELETE FROM documents WHERE path LIKE ?1',
      variables: [Variable<String>(path)],
      updates: {documents},
      updateKind: UpdateKind.delete,
    );
  }

  Future<int> _deleteAll() {
    return customUpdate(
      'DELETE FROM documents',
      variables: [],
      updates: {documents},
      updateKind: UpdateKind.delete,
    );
  }

  Future<List<Doc>> _set(String path, Map<String, dynamic> data, int? ttl,
      int created, int updated) {
    return customWriteReturning(
        'INSERT OR REPLACE INTO documents (path, data, ttl, created, updated) VALUES (?1, ?2, ?3, ?4, ?5) RETURNING *',
        variables: [
          Variable<String>(path),
          Variable<String>(Documents.$converterdata.toSql(data)),
          Variable<int>(ttl),
          Variable<int>(created),
          Variable<int>(updated)
        ],
        updates: {
          documents
        }).then((rows) => Future.wait(rows.map(documents.mapFromRow)));
  }

  Future<int> _setTtl(int? ttl, int updated, String path) {
    return customUpdate(
      'UPDATE documents SET ttl = ?1, updated = ?2 WHERE path = ?3',
      variables: [
        Variable<int>(ttl),
        Variable<int>(updated),
        Variable<String>(path)
      ],
      updates: {documents},
      updateKind: UpdateKind.update,
    );
  }

  Future<int> _removeTTl(int updated, String path) {
    return customUpdate(
      'UPDATE documents SET ttl = NULL, updated = ?1 WHERE path = ?2',
      variables: [Variable<int>(updated), Variable<String>(path)],
      updates: {documents},
      updateKind: UpdateKind.update,
    );
  }

  Selectable<Doc> _get(String path) {
    return customSelect(
        'SELECT * FROM documents WHERE path = ?1 AND((ttl IS NOT NULL AND ttl + updated < unixepoch())OR ttl IS NULL)',
        variables: [
          Variable<String>(path)
        ],
        readsFrom: {
          documents,
        }).asyncMap(documents.mapFromRow);
  }

  Selectable<Doc> _getAll() {
    return customSelect(
        'SELECT * FROM documents WHERE((ttl IS NOT NULL AND ttl + updated < unixepoch())OR ttl IS NULL)',
        variables: [],
        readsFrom: {
          documents,
        }).asyncMap(documents.mapFromRow);
  }

  Selectable<Doc> _getAllFilter(List<String> paths) {
    var $arrayStartIndex = 1;
    final expandedpaths = $expandVar($arrayStartIndex, paths.length);
    $arrayStartIndex += paths.length;
    return customSelect(
        'SELECT * FROM documents WHERE path IN ($expandedpaths) AND((ttl IS NOT NULL AND ttl + updated < unixepoch())OR ttl IS NULL)',
        variables: [
          for (var $ in paths) Variable<String>($)
        ],
        readsFrom: {
          documents,
        }).asyncMap(documents.mapFromRow);
  }

  Future<int> _removeExpired() {
    return customUpdate(
      'DELETE FROM documents WHERE ttl IS NOT NULL AND ttl + updated < unixepoch()',
      variables: [],
      updates: {documents},
      updateKind: UpdateKind.delete,
    );
  }

  Selectable<int> _getCollectionCount(String prefix) {
    return customSelect(
        'SELECT COUNT(*) AS count FROM documents WHERE(path LIKE ?1 AND(LENGTH(path) - LENGTH("REPLACE"(path, \'/\', \'\')))=(LENGTH(?1) - LENGTH("REPLACE"(?1, \'/\', \'\'))))AND((ttl IS NOT NULL AND ttl + updated < unixepoch())OR ttl IS NULL)',
        variables: [
          Variable<String>(prefix)
        ],
        readsFrom: {
          documents,
        }).map((QueryRow row) => row.read<int>('count'));
  }

  Selectable<Doc> _getCollection(String prefix) {
    return customSelect(
        'SELECT * FROM documents WHERE(path LIKE ?1 AND(LENGTH(path) - LENGTH("REPLACE"(path, \'/\', \'\')))=(LENGTH(?1) - LENGTH("REPLACE"(?1, \'/\', \'\'))))AND((ttl IS NOT NULL AND ttl + updated < unixepoch())OR ttl IS NULL)ORDER BY created',
        variables: [
          Variable<String>(prefix)
        ],
        readsFrom: {
          documents,
        }).asyncMap(documents.mapFromRow);
  }

  Selectable<Doc> _getCollectionRecursive(String prefix) {
    return customSelect(
        'SELECT * FROM documents WHERE path LIKE ?1 AND((ttl IS NOT NULL AND ttl + updated < unixepoch())OR ttl IS NULL)ORDER BY created',
        variables: [
          Variable<String>(prefix)
        ],
        readsFrom: {
          documents,
        }).asyncMap(documents.mapFromRow);
  }
}
