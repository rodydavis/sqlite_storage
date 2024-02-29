import 'dart:convert';

import 'package:mime/mime.dart';
import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:path/path.dart' as p;

import 'database/database.dart';
import 'database/selectable.dart';

const _tableFiles = '_files';
const _tableDirectories = '_directories';

const _createSql = '''
CREATE TABLE $_tableFiles (
  path TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  data BLOB,
  mime_type TEXT,
  size INTEGER,
  parent_id INTEGER NOT NULL REFERENCES $_tableDirectories(id),
  created INTEGER,
  updated INTEGER,
  UNIQUE (path)
);
---
CREATE TABLE $_tableDirectories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  parent_id INTEGER REFERENCES $_tableDirectories(id),
  path TEXT NOT NULL,
  name TEXT NOT NULL,
  UNIQUE (path)
);
''';

class FilesDatabase extends Dao {
  FilesDatabase(super.database);

  @override
  Future<void> migrate(int toVersion, SqliteWriteContext tx, bool down) async {
    if (toVersion == 1) {
      if (down) {
        await tx.execute('DROP TABLE $_tableFiles');
        await tx.execute('DROP TABLE $_tableDirectories');
      } else {
        final statements = _createSql.split('---');
        for (final stmt in statements) {
          await tx.execute(stmt);
        }
        await tx.getOptional(
          'INSERT INTO $_tableDirectories (path, name) VALUES (?, ?)',
          [p.separator, p.separator],
        );
      }
    }
  }

  Future<void> clear() async {
    await database.db.execute('DELETE FROM $_tableFiles');
    await database.db.execute('DELETE FROM $_tableDirectories');
  }

  DatabaseDirectory directory(String path) => DatabaseDirectory(this, path);

  DatabaseFile file(String path) => DatabaseFile(this, path);
}

typedef Metadata = ({
  DateTime created,
  DateTime updated,
  String? mimeType,
  int? size,
});

abstract class DatabaseFileEntity {
  final FilesDatabase db;
  final String path;
  DatabaseFileEntity(this.db, this.path);

  String get basename => p.basename(path);
  String get dirname => p.dirname(path);

  Future<bool> exists();

  Future<void> delete();

  bool get isFile;
  bool get isDirectory;
}

class DatabaseDirectory extends DatabaseFileEntity {
  DatabaseDirectory(super.db, super.path);

  DatabaseFile file(String target) {
    return DatabaseFile(db, p.join(path, target));
  }

  DatabaseDirectory directory(String target) {
    return DatabaseDirectory(db, p.join(path, target));
  }

  @override
  bool get isFile => false;

  @override
  bool get isDirectory => true;

  @override
  Future<bool> exists() async {
    final result = await db.database.db.getOptional(
      'SELECT path FROM $_tableDirectories WHERE path = ?',
      [path],
    );
    return result != null;
  }

  @override
  Future<void> delete() async {
    await db.database.db.execute(
      'DELETE FROM $_tableDirectories WHERE path LIKE ?',
      ['$path%'],
    );
    await db.database.db.execute(
      'DELETE FROM $_tableFiles WHERE path LIKE ?',
      ['$path%'],
    );
  }

  Future<List<DatabaseFileEntity>> list({bool recursive = false}) async {
    ResultSet results;
    if (recursive) {
      results = await db.database.db.getAll(
        'SELECT path FROM $_tableFiles WHERE path LIKE ?',
        ['$path%'],
      );
    } else {
      final dir = await db.database.db.get(
        'SELECT id FROM $_tableDirectories WHERE path = ?',
        [path],
      );
      final id = dir['id'] as int;
      results = await db.database.db.getAll(
        'SELECT path FROM $_tableFiles WHERE parent_id = ?',
        [id],
      );
    }
    return results
        .map((e) => e['path'] as String)
        .map((e) => DatabaseFile(db, e))
        .toList();
  }
}

class DatabaseFile extends DatabaseFileEntity {
  DatabaseFile(super.db, super.path);

  String get extension => p.extension(path);

  @override
  bool get isFile => true;

  @override
  bool get isDirectory => false;

  @override
  Future<bool> exists() async {
    final result = await db.database.db.getOptional(
      'SELECT path FROM $_tableFiles WHERE path = ?',
      [path],
    );
    return result != null;
  }

  @override
  Future<void> delete() async {
    await db.database.db.execute(
      'DELETE FROM $_tableFiles WHERE path = ?',
      [path],
    );
  }

  Future<Metadata> metadata() async {
    final result = await db.database.db.getOptional(
      'SELECT created, updated, mime_type, size FROM $_tableFiles WHERE path = ?',
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

  Future<void> writeAsBytes(List<int> data) async {
    return db.database.db.writeTransaction((tx) async {
      final existing = await tx.getOptional(
        'SELECT path FROM $_tableFiles WHERE path = ?',
        [path],
      );
      if (existing == null) {
        final parts = p.split(path);
        String current = '';
        int? parentId;
        for (final part in parts.take(parts.length - 1)) {
          final target = current.isEmpty ? part : p.join(current, part);
          final dir = await tx.getOptional(
            'SELECT id FROM $_tableDirectories WHERE path = ?',
            [target],
          );
          if (dir == null) {
            final result = await tx.execute(
              'INSERT INTO $_tableDirectories (parent_id, path, name) VALUES (?, ?, ?) RETURNING *',
              [parentId, target, part],
            );
            parentId = result.first['id'] as int;
          } else {
            parentId = dir['id'] as int;
          }
          current = target;
        }
        await tx.execute(
          'INSERT INTO $_tableFiles (path, name, data, mime_type, size, parent_id, created, updated) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
          [
            path,
            p.basename(path),
            data,
            lookupMimeType(path, headerBytes: data),
            data.length,
            parentId,
            DateTime.now().millisecondsSinceEpoch,
            DateTime.now().millisecondsSinceEpoch
          ],
        );
      } else {
        await tx.execute(
          'UPDATE $_tableFiles SET data = ?, mime_type = ?, size = ?, updated = ? WHERE path = ?',
          [
            data,
            lookupMimeType(path, headerBytes: data),
            data.length,
            DateTime.now().millisecondsSinceEpoch,
            path,
          ],
        );
      }
    });
  }

  Future<void> rename(String newPath) async {
    final bytes = await readAsBytes();
    await delete();
    if (bytes == null) return;
    await DatabaseFile(db, newPath).writeAsBytes(bytes);
  }

  Selectable<List<int>?> _select() {
    return db.database.db.select(
      'SELECT data FROM $_tableFiles WHERE path = ?',
      args: [path],
      mapper: (row) => row['data'] as List<int>?,
    );
  }

  Future<List<int>?> readAsBytes() async {
    return await _select().getSingleOrNull();
  }

  Stream<List<int>?> watchAsBytes() {
    return _select().watchSingleOrNull();
  }

  Stream<String?> watchAsString() {
    return watchAsBytes().map(
      (bytes) => bytes == null ? null : utf8.decode(bytes),
    );
  }

  Future<String?> readAsString() async {
    final bytes = await readAsBytes();
    if (bytes == null) return null;
    return utf8.decode(bytes);
  }

  Future<void> writeAsString(String data) async {
    await writeAsBytes(utf8.encode(data));
  }
}
