// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'files.dart';

// ignore_for_file: type=lint
mixin _$FilesDaoMixin on DatabaseAccessor<DriftStorage> {
  Files get files => attachedDatabase.files;
  KeyValue get keyValue => attachedDatabase.keyValue;
  Documents get documents => attachedDatabase.documents;
  Analytics get analytics => attachedDatabase.analytics;
  Nodes get nodes => attachedDatabase.nodes;
  Edges get edges => attachedDatabase.edges;
  Logging get logging => attachedDatabase.logging;
  Requests get requests => attachedDatabase.requests;
  OfflineRequestQueue get offlineRequestQueue =>
      attachedDatabase.offlineRequestQueue;
  OfflineRequestQueueFiles get offlineRequestQueueFiles =>
      attachedDatabase.offlineRequestQueueFiles;
  Selectable<FileData> _search(String query) {
    return customSelect(
        'SELECT * FROM files WHERE(path LIKE ?1 OR data LIKE ?1)',
        variables: [
          Variable<String>(query)
        ],
        readsFrom: {
          files,
        }).asyncMap(files.mapFromRow);
  }

  Selectable<FileData> _filter(String query) {
    return customSelect('SELECT * FROM files WHERE path LIKE ?1', variables: [
      Variable<String>(query)
    ], readsFrom: {
      files,
    }).asyncMap(files.mapFromRow);
  }

  Future<int> _delete(String path) {
    return customUpdate(
      'DELETE FROM files WHERE path = ?1',
      variables: [Variable<String>(path)],
      updates: {files},
      updateKind: UpdateKind.delete,
    );
  }

  Future<int> _deleteWhere(List<String> paths) {
    var $arrayStartIndex = 1;
    final expandedpaths = $expandVar($arrayStartIndex, paths.length);
    $arrayStartIndex += paths.length;
    return customUpdate(
      'DELETE FROM files WHERE path IN ($expandedpaths)',
      variables: [for (var $ in paths) Variable<String>($)],
      updates: {files},
      updateKind: UpdateKind.delete,
    );
  }

  Future<int> _deleteFilter(String path) {
    return customUpdate(
      'DELETE FROM files WHERE path LIKE ?1',
      variables: [Variable<String>(path)],
      updates: {files},
      updateKind: UpdateKind.delete,
    );
  }

  Future<int> _deleteAll() {
    return customUpdate(
      'DELETE FROM files',
      variables: [],
      updates: {files},
      updateKind: UpdateKind.delete,
    );
  }

  Future<List<FileData>> _set(String path, Uint8List? data, String? mimeType,
      int? size, int created, int updated) {
    return customWriteReturning(
        'INSERT OR REPLACE INTO files (path, data, mime_type, size, created, updated) VALUES (?1, ?2, ?3, ?4, ?5, ?6) RETURNING *',
        variables: [
          Variable<String>(path),
          Variable<Uint8List>(data),
          Variable<String>(mimeType),
          Variable<int>(size),
          Variable<int>(created),
          Variable<int>(updated)
        ],
        updates: {
          files
        }).then((rows) => Future.wait(rows.map(files.mapFromRow)));
  }

  Future<int> _update(
      Uint8List? data, String? mimeType, int? size, int updated, String path) {
    return customUpdate(
      'UPDATE files SET data = ?1, mime_type = ?2, size = ?3, updated = ?4 WHERE path = ?5',
      variables: [
        Variable<Uint8List>(data),
        Variable<String>(mimeType),
        Variable<int>(size),
        Variable<int>(updated),
        Variable<String>(path)
      ],
      updates: {files},
      updateKind: UpdateKind.update,
    );
  }

  Selectable<FileData> _get(String path) {
    return customSelect('SELECT * FROM files WHERE path = ?1', variables: [
      Variable<String>(path)
    ], readsFrom: {
      files,
    }).asyncMap(files.mapFromRow);
  }

  Selectable<FileData> _getAll() {
    return customSelect('SELECT * FROM files', variables: [], readsFrom: {
      files,
    }).asyncMap(files.mapFromRow);
  }

  Selectable<FileData> _getAllFilter(List<String> paths) {
    var $arrayStartIndex = 1;
    final expandedpaths = $expandVar($arrayStartIndex, paths.length);
    $arrayStartIndex += paths.length;
    return customSelect('SELECT * FROM files WHERE path IN ($expandedpaths)',
        variables: [
          for (var $ in paths) Variable<String>($)
        ],
        readsFrom: {
          files,
        }).asyncMap(files.mapFromRow);
  }

  Selectable<int> _getFilesForDirectoryCount(String prefix) {
    return customSelect(
        'SELECT COUNT(*) AS count FROM files WHERE(path LIKE ?1 AND(LENGTH(path) - LENGTH("REPLACE"(path, \'/\', \'\')))=(LENGTH(?1) - LENGTH("REPLACE"(?1, \'/\', \'\'))))',
        variables: [
          Variable<String>(prefix)
        ],
        readsFrom: {
          files,
        }).map((QueryRow row) => row.read<int>('count'));
  }

  Selectable<int> _getFilesForDirectoryRecursiveCount(String prefix) {
    return customSelect(
        'SELECT COUNT(*) AS count FROM files WHERE path LIKE ?1',
        variables: [
          Variable<String>(prefix)
        ],
        readsFrom: {
          files,
        }).map((QueryRow row) => row.read<int>('count'));
  }

  Selectable<FileData> _getFilesForDirectory(String prefix) {
    return customSelect(
        'SELECT * FROM files WHERE(path LIKE ?1 AND(LENGTH(path) - LENGTH("REPLACE"(path, \'/\', \'\')))=(LENGTH(?1) - LENGTH("REPLACE"(?1, \'/\', \'\'))))ORDER BY created',
        variables: [
          Variable<String>(prefix)
        ],
        readsFrom: {
          files,
        }).asyncMap(files.mapFromRow);
  }

  Selectable<FileData> _getFilesForDirectoryRecursive(String prefix) {
    return customSelect(
        'SELECT * FROM files WHERE path LIKE ?1 ORDER BY created',
        variables: [
          Variable<String>(prefix)
        ],
        readsFrom: {
          files,
        }).asyncMap(files.mapFromRow);
  }
}
