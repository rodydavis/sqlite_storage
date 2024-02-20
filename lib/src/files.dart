import 'dart:convert';

import 'package:sqlite_async/sqlite_async.dart';

import 'database/database.dart';
import 'database/selectable.dart';

class FilesDatabase extends Dao {
  FilesDatabase(super.database);

  @override
  Future<void> migrate(int toVersion, SqliteWriteContext tx, bool down) async {
    if (toVersion == 1) {
      if (down) {
        await tx.execute('DROP TABLE files');
      } else {
        await tx.execute(_createSql);
      }
    }
  }

  Selectable<List<int>?> selectAsBytes(String path) {
    return database.db.select(
      'SELECT data FROM files WHERE path = ?',
      args: [path],
      mapper: (row) => row['data'] as List<int>?,
    );
  }

  Future<List<int>?> readAsBytes(String path) async {
    return await selectAsBytes(path).getSingleOrNull();
  }

  Stream<List<int>?> watchAsBytes(String path) {
    return selectAsBytes(path).watchSingleOrNull();
  }

  Future<String?> readAsString(String path) async {
    final bytes = await readAsBytes(path);
    if (bytes == null) return null;
    return utf8.decode(bytes);
  }

  Stream<String?> watchAsString(String path) {
    return watchAsBytes(path).map(
      (bytes) => bytes == null ? null : utf8.decode(bytes),
    );
  }

  Future<void> writeAsBytes(String path, List<int> data) async {
    final existing = await database.db.getOptional(
      'SELECT path FROM files WHERE path = ?',
      [path],
    );
    if (existing == null) {
      await database.db.execute(
        'INSERT INTO files (path, data, created, updated) VALUES (?, ?, ?, ?)',
        [
          path,
          data,
          DateTime.now().millisecondsSinceEpoch,
          DateTime.now().millisecondsSinceEpoch
        ],
      );
    } else {
      await database.db.execute(
        'UPDATE files SET data = ?, updated = ? WHERE path = ?',
        [data, DateTime.now().millisecondsSinceEpoch, path],
      );
    }
  }

  Future<void> writeAsString(String path, String data) async {
    await writeAsBytes(path, utf8.encode(data));
  }

  Future<bool> exists(String path) async {
    final result = await database.db.getOptional(
      'SELECT path FROM files WHERE path = ?',
      [path],
    );
    return result != null;
  }

  Future<Metadata> metadata(String path) async {
    final result = await database.db.getOptional(
      'SELECT created, updated FROM files WHERE path = ?',
      [path],
    );
    if (result == null) {
      throw ArgumentError('File not found: $path');
    }
    return (
      created: DateTime.fromMillisecondsSinceEpoch(result['created'] as int),
      updated: DateTime.fromMillisecondsSinceEpoch(result['updated'] as int),
    );
  }

  Future<void> delete(String path) async {
    await database.db.execute(
      'DELETE FROM files WHERE path = ?',
      [path],
    );
  }

  Future<void> clear() async {
    await database.db.execute('DELETE FROM files');
  }
}

const _createSql = '''
CREATE TABLE files (
  path TEXT PRIMARY KEY,
  data BLOB,
  created INTEGER,
  updated INTEGER,
  UNIQUE (path)
);
''';

typedef Metadata = ({
  DateTime created,
  DateTime updated,
});
