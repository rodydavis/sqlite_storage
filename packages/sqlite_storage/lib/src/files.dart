import 'dart:convert';

import 'package:mime/mime.dart';
import 'package:sqlite_async/sqlite_async.dart';

import 'database/database.dart';
import 'database/selectable.dart';

const _table = '_files';

const _createSql = '''
CREATE TABLE $_table (
  path TEXT PRIMARY KEY,
  data BLOB,
  mime_type TEXT,
  size INTEGER,
  created INTEGER,
  updated INTEGER,
  UNIQUE (path)
);
''';

class FilesDatabase extends Dao {
  FilesDatabase(super.database);

  @override
  Future<void> migrate(int toVersion, SqliteWriteContext tx, bool down) async {
    if (toVersion == 1) {
      if (down) {
        await tx.execute('DROP TABLE $_table');
      } else {
        await tx.execute(_createSql);
      }
    }
  }

  Selectable<List<int>?> selectAsBytes(String path) {
    return database.db.select(
      'SELECT data FROM $_table WHERE path = ?',
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
      'SELECT path FROM $_table WHERE path = ?',
      [path],
    );
    if (existing == null) {
      await database.db.execute(
        'INSERT INTO $_table (path, data, mime_type, size, created, updated) VALUES (?, ?, ?, ?, ?, ?)',
        [
          path,
          data,
          lookupMimeType(path, headerBytes: data),
          data.length,
          DateTime.now().millisecondsSinceEpoch,
          DateTime.now().millisecondsSinceEpoch
        ],
      );
    } else {
      await database.db.execute(
        'UPDATE $_table SET data = ?, updated = ? WHERE path = ?',
        [data, DateTime.now().millisecondsSinceEpoch, path],
      );
    }
  }

  Future<void> writeAsString(String path, String data) async {
    await writeAsBytes(path, utf8.encode(data));
  }

  Future<bool> exists(String path) async {
    final result = await database.db.getOptional(
      'SELECT path FROM $_table WHERE path = ?',
      [path],
    );
    return result != null;
  }

  Future<Metadata> metadata(String path) async {
    final result = await database.db.getOptional(
      'SELECT created, updated, mime_type, size FROM $_table WHERE path = ?',
      [path],
    );
    if (result == null) {
      throw ArgumentError('File not found: $path');
    }
    return (
      created: DateTime.fromMillisecondsSinceEpoch(result['created'] as int),
      updated: DateTime.fromMillisecondsSinceEpoch(result['updated'] as int),
      mimeType: result['mime_type'] as String?,
      size: result['size'] as int?,
    );
  }

  Future<void> delete(String path) async {
    await database.db.execute(
      'DELETE FROM $_table WHERE path = ?',
      [path],
    );
  }

  Future<void> clear() async {
    await database.db.execute('DELETE FROM $_table');
  }
}

typedef Metadata = ({
  DateTime created,
  DateTime updated,
  String? mimeType,
  int? size,
});
