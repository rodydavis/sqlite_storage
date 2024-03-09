import 'dart:async';
import 'dart:convert';

import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';

import 'database/database.dart';
import 'database/id.dart' as id_generator;
import 'database/selectable.dart';

typedef JsonDocument = Map<String, Object?>;

const _table = '_documents';

const _createSql = '''
CREATE TABLE $_table (
  path TEXT PRIMARY KEY,
  data TEXT,
  ttl INTEGER,
  created INTEGER NOT NULL,
  updated INTEGER NOT NULL,
  UNIQUE(path)
);
''';

// TODO: jsonB, filters - https://pub.dev/packages/query
class DocumentDatabase extends Dao {
  DocumentDatabase(super.database);

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

  Document doc(String collection, String id) =>
      Document(this, '$collection/$id');
  Collection collection(String prefix) => Collection(this, prefix);

  String generateId() => id_generator.generateId();

  DocumentSnapshot _mapper(Row r) {
    return DocumentSnapshot(Document(this, r['path'] as String), r);
  }

  Selectable<DocumentSnapshot> select([
    String sql =
        'SELECT * FROM $_table WHERE (ttl IS NOT NULL AND ttl + updated > ?) OR ttl IS NULL',
    List<Object?> args = const [],
  ]) {
    return database.db.select(
      sql,
      mapper: _mapper,
      args: [
        DateTime.now().millisecondsSinceEpoch,
        ...args,
      ],
    );
  }

  Selectable<DocumentSnapshot> query(String query) {
    return database.db.select(
      'SELECT * FROM $_table WHERE path LIKE :query OR data LIKE :query',
      args: ['%$query%'],
      mapper: _mapper,
    );
  }

  Future<void> clear() async {
    await database.db.execute('DELETE FROM $_table');
  }

  Future<void> removeExpired() async {
    await database.db.execute(
      'DELETE FROM $_table WHERE ttl IS NOT NULL AND ttl + updated < :date',
      [DateTime.now().millisecondsSinceEpoch],
    );
  }

  @override
  Future<void> open() async {
    await removeExpired();
  }
}

class Document {
  Document(this.db, this.path);
  final DocumentDatabase db;
  final String path;
  List<String> get pathParts => path.split('/');
  String get id => pathParts.last;

  Collection collection(String prefix) => Collection(db, '$path/$prefix');

  Future<void> set(JsonDocument data) async {
    var exists = await db.database.db.getOptional(
      'SELECT * FROM $_table WHERE path = :path',
      [path],
    );
    if (exists != null && _expired(exists)) {
      await remove();
      exists = null;
    }
    if (exists != null) {
      final sql = StringBuffer(
        'UPDATE $_table SET data = :data, updated = :date',
      );
      final args = [
        jsonEncode(data),
        DateTime.now().millisecondsSinceEpoch,
        path,
      ];
      sql.write(' WHERE path = :path');
      await db.database.db.execute(sql.toString(), args);
    } else {
      List<String> columns = ['path', 'data', 'created', 'updated'];
      final args = [
        path,
        jsonEncode(data),
        DateTime.now().millisecondsSinceEpoch,
        DateTime.now().millisecondsSinceEpoch,
      ];
      final sql = StringBuffer('INSERT INTO $_table (');
      sql.writeAll(columns, ', ');
      sql.write(') VALUES (');
      sql.writeAll(columns.map((_) => '?'), ', ');
      sql.write(')');
      await db.database.db.execute(sql.toString(), args);
    }
  }

  // TODO: https://www.sqlite.org/json1.html#jrm
  /// Partial update
  Future<void> update(JsonDocument data) async {
    final exists = await get();
    if (exists == null) {
      // Create a new document if it doesn't exist
      await set(data);
      return;
    }
    final current = exists.data ?? {};
    final updated = Map<String, Object?>.from(current)..addAll(data);
    await set(updated);
  }

  Future<void> remove() {
    return db.database.db.execute(
      'DELETE FROM $_table WHERE path = :path',
      [path],
    );
  }

  Future<DocumentSnapshot?> get() async {
    return await db.database.db.getOptional(
      'SELECT * FROM $_table WHERE path = :path',
      [path],
    ).then((value) => DocumentSnapshot(this, value));
  }

  Stream<DocumentSnapshot> watch({
    Duration throttle = const Duration(milliseconds: 30),
  }) {
    return db.database.db
        .watch(
      'SELECT * FROM $_table WHERE path = :path',
      parameters: [path],
      throttle: throttle,
    )
        .map((results) {
      if (results.isEmpty) return DocumentSnapshot(this, null);
      return DocumentSnapshot(this, results.first);
    });
  }

  Future<void> setTTl(Duration ttl) async {
    await db.database.db.execute(
      'UPDATE $_table SET ttl = :ttl, updated = :date WHERE path = :path',
      [
        ttl.inMilliseconds,
        DateTime.now().millisecondsSinceEpoch,
        path,
      ],
    );
  }

  Future<void> removeTTl() async {
    await db.database.db.execute(
      'UPDATE $_table SET ttl = NULL, updated = :date WHERE path = :path',
      [
        DateTime.now().millisecondsSinceEpoch,
        path,
      ],
    );
  }

  @override
  String toString() {
    return 'Document($path)';
  }

  @override
  bool operator ==(Object other) {
    return other is Document && other.path == path;
  }

  @override
  int get hashCode => path.hashCode;

  // TODO: https://www.sqlite.org/json1.html#jmini
  Selectable<Object?> jsonExtract(List<String> columns) {
    final fields = columns.map((key) => "'\$.$key'").join(',');
    return db.database.query(
      _table,
      where: 'path = :path',
      whereArgs: [path],
      columns: ['json_extract(data, $fields) as value'],
      mapper: (row) => row['value'],
    );
  }
}

class DocumentSnapshot extends Document {
  DocumentSnapshot(Document doc, this._row) : super(doc.db, doc.path);
  final Row? _row;

  JsonDocument? get data {
    if (!exists || expired) return null;
    return jsonDecode(_row!['data'] as String) as JsonDocument;
  }

  bool get exists => _row != null;
  bool get expired => _row != null && _expired(_row!);

  @override
  String toString() {
    return 'DocumentSnapshot($path, $data)';
  }

  @override
  bool operator ==(Object other) {
    return other is DocumentSnapshot &&
        other.path == path &&
        other.data == data;
  }

  @override
  int get hashCode => path.hashCode ^ data.hashCode;
}

class Collection {
  Collection(this.db, String prefix)
      : prefix = prefix.endsWith('/') ? prefix : '$prefix/';
  final DocumentDatabase db;
  final String prefix;

  Document doc([String? id]) => Document(db, '$prefix${id ?? db.generateId()}');

  Future<void> clear() async {
    await db.database.db.execute(
      'DELETE FROM $_table WHERE path LIKE :prefix',
      ['$prefix%'],
    );
  }

  Selectable<DocumentSnapshot> select() {
    return db.database.db.select(
      'SELECT * FROM $_table WHERE path LIKE :prefix ORDER BY created',
      args: ['$prefix%'],
      mapper: db.database.documents._mapper,
    );
  }

  Future<int> getCount() async {
    final row = await db.database.db.get(
      'SELECT COUNT(*) AS count FROM $_table WHERE path LIKE :prefix',
      ['$prefix%'],
    );
    return row['count'] as int;
  }

  Stream<int> watchCount({
    Duration throttle = const Duration(milliseconds: 30),
  }) {
    return db.database.db
        .watch(
          'SELECT COUNT(*) AS count FROM $_table WHERE path LIKE :prefix',
          parameters: ['$prefix%'],
          throttle: throttle,
        )
        .map((results) => results.first['count'] as int);
  }

  Future<void> addAll(Map<String, JsonDocument> values) async {
    await db.database.db.writeTransaction((tx) async {
      for (final entry in values.entries) {
        await tx.execute(
          'INSERT INTO $_table (path, data, created, updated) VALUES (:path, :data, :date, :date)',
          [
            prefix + entry.key,
            jsonEncode(entry.value),
            DateTime.now().millisecondsSinceEpoch,
          ],
        );
      }
    });
  }

  Future<void> removeAll(List<String> ids) async {
    await db.database.db.writeTransaction((tx) async {
      for (final id in ids) {
        await tx.execute(
          'DELETE FROM $_table WHERE path = :path',
          [prefix + id],
        );
      }
    });
  }

  @override
  String toString() {
    return 'Collection($prefix)';
  }

  @override
  bool operator ==(Object other) {
    return other is Collection && other.prefix == prefix;
  }

  @override
  int get hashCode => prefix.hashCode;
}

bool _expired(Row row) {
  final updated = row['updated'] as int;
  final ttl = row['ttl'] as int?;
  if (ttl == null) return false;
  return DateTime.now().millisecondsSinceEpoch - updated > ttl;
}