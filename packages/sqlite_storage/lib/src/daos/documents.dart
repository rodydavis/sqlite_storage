import 'package:drift/drift.dart';
// import 'package:query/query.dart' as q;

import '../database.dart';

part 'documents.g.dart';

typedef DocumentData = Map<String, Object?>;

@DriftAccessor(include: {'../sql/documents.drift'})
class DocumentsDao extends DatabaseAccessor<DriftStorage>
    with _$DocumentsDaoMixin {
  DocumentsDao(super.db);

  Future<void> remove(String path, {bool recursive = false}) {
    if (recursive) {
      return _deleteFilter('$path%');
    } else {
      return _delete(path);
    }
  }

  Future<void> removeAll(List<String> paths) {
    return _deleteWhere(paths);
  }

  Selectable<DocumentSnapshot> search(String query) {
    return _search('%$query%').map((e) => e.toSnapshot(this));
  }

  Selectable<DocumentSnapshot?> get(String path) {
    return _get(path).map((e) => e.toSnapshot(this));
  }

  Selectable<DocumentSnapshot> getAll({
    List<String> paths = const [],
  }) {
    if (paths.isEmpty) {
      return _getAll().map((e) => e.toSnapshot(this));
    } else {
      return _getAllFilter(paths).map((e) => e.toSnapshot(this));
    }
  }

  Future<void> clear({
    List<String> paths = const [],
  }) {
    if (paths.isEmpty) {
      return _deleteAll();
    } else {
      return _deleteWhere(paths);
    }
  }

  Document doc(String collection, String id) {
    return Document(this, '$collection/$id');
  }

  Collection collection(String prefix) {
    return Collection(this, prefix);
  }

  Future<void> removeExpired() {
    return _removeExpired();
  }

  // Selectable<Doc> queryRaw<T extends Comparable>(
  //   String search, {
  //   String? pathEquals,
  //   String? pathLike,
  // }) {
  //   final sql = StringBuffer('SELECT * FROM documents ');
  //   final args = <Variable>[];
  //   bool where = false;

  //   if (pathEquals != null) {
  //     sql.writeln("WHERE path = :path ");
  //     args.add(Variable(pathEquals));
  //     where = true;
  //   } else if (pathLike != null) {
  //     sql.writeln("WHERE path != :path ");
  //     args.add(Variable(pathLike));
  //     where = true;
  //   }

  //   final result = q.parseQuery(search);
  //   convertQuery(result, sql, args, where);

  //   return customSelect(
  //     sql.toString(),
  //     variables: args,
  //     readsFrom: {documents},
  //   ).asyncMap(documents.mapFromRow);
  // }

  // void convertQuery(
  //   q.Query target,
  //   StringBuffer sql,
  //   List<Variable> args,
  //   bool where,
  // ) {
  //   //
  // }

  Selectable<Doc> query<T extends Comparable>({
    String? pathEquals,
    String? pathLike,
    Filter? filters,
  }) {
    final sql = StringBuffer('SELECT * FROM documents ');
    final args = <Variable>[];
    bool where = false;

    if (pathEquals != null) {
      sql.writeln("WHERE path = :path ");
      args.add(Variable(pathEquals));
      where = true;
    } else if (pathLike != null) {
      sql.writeln("WHERE path != :path ");
      args.add(Variable(pathLike));
      where = true;
    }

    if (filters != null) {
      if (!where) sql.write('WHERE ');
      sql.write(filters.toString());
    }

    return customSelect(
      sql.toString(),
      variables: args,
      readsFrom: {documents},
    ).asyncMap(documents.mapFromRow);
  }
}

enum QueryOperator {
  greaterThan('>'),
  greaterThanEquals('>='),
  lessThan('<'),
  lessThanEquals('<='),
  notEquals('!='),
  equals('=');

  const QueryOperator(this.sql);
  final String sql;
}

// class DocumentMapper<T> {
//   final DocumentsDao db;
//   final T Function(DocumentData) read;
//   final DocumentData Function(T) save;

//   const DocumentMapper(
//     this.db, {
//     required this.read,
//     required this.save,
//   });
// }

sealed class Filter {
  final String value;
  Filter(this.value);

  @override
  String toString() => '($value)';
}

class LiteralValue extends Filter {
  final Object? object;

  LiteralValue(this.object)
      : super(() {
          if (object == null) return 'NULL';
          if (object is String) return "'$object'";
          return '$object';
        }());
}

class JsonField extends Filter {
  final String field;

  JsonField(this.field) : super("json_extract(data, '\$.$field')");
}

class AndFilter extends Filter {
  final Filter left;
  final Filter right;

  AndFilter(this.left, this.right) : super('$left AND $right');
}

class OrFilter extends Filter {
  final Filter left;
  final Filter right;

  OrFilter(this.left, this.right) : super('$left OR $right');
}

class CompareFilter extends Filter {
  final Filter left;
  final Filter right;
  final QueryOperator operator;

  CompareFilter(this.left, this.operator, this.right)
      : super('$left ${operator.sql} $right');
}

class Document {
  Document(this.db, this.path) {
    assert(_validPath(path), 'path "$path" must contain odd number of /');
  }
  final DocumentsDao db;
  final String path;
  List<String> get pathParts => path.split('/');
  String get id => pathParts.last;

  static bool _validPath(String path) => path.pathSeparators.isOdd;

  Collection collection(String prefix) => Collection(db, '$path/$prefix');

  Future<void> set(
    DocumentData? data, {
    Duration? ttl,
    DateTime? created,
    DateTime? updated,
  }) {
    return db._set(
      path,
      data ?? {},
      ttl?.inSeconds,
      (created ?? DateTime.now()).millisecondsSinceEpoch,
      (updated ?? DateTime.now()).millisecondsSinceEpoch,
    );
  }

  // TODO: https://www.sqlite.org/json1.html#jrm
  /// Partial update
  Future<void> update(DocumentData data) async {
    final exists = await select().getSingleOrNull();
    if (exists == null) {
      // Create a new document if it doesn't exist
      await set(data);
      return;
    }
    final current = exists.data ?? {};
    final updated = Map<String, Object?>.from(current)..addAll(data);
    await set(updated);
  }

  Future<void> remove() => db._delete(path);

  Selectable<DocumentSnapshot?> select() {
    return db._get(path).map((e) => DocumentSnapshot(this, e));
  }

  Future<DocumentSnapshot?> get() {
    return select().getSingleOrNull();
  }

  Stream<DocumentSnapshot?> watch() {
    return select().watchSingleOrNull();
  }

  Future<void> setTTl(Duration ttl) => db._setTtl(
        ttl.inSeconds,
        DateTime.now().millisecondsSinceEpoch,
        path,
      );

  Future<void> removeTTl() => db._removeTTl(
        DateTime.now().millisecondsSinceEpoch,
        path,
      );

  @override
  String toString() => 'Document($path)';

  @override
  bool operator ==(Object other) {
    return other is Document && other.path == path;
  }

  @override
  int get hashCode => path.hashCode;

  // // TODO: https://www.sqlite.org/json1.html#jmini
  // Selectable<Object?> jsonExtract(List<String> columns) {
  //   final fields = columns.map((key) => "'\$.$key'").join(',');
  //   return db.database.query(
  //     _table,
  //     where: 'path = :path',
  //     whereArgs: [path],
  //     columns: ['json_extract(data, $fields) as value'],
  //     mapper: (row) => row['value'],
  //   );
  // }
}

class DocumentSnapshot extends Document {
  DocumentSnapshot(Document doc, this._row) : super(doc.db, doc.path);
  final Doc? _row;

  DocumentData? get data {
    if (!exists || expired) return null;
    return _row!.data;
  }

  bool get exists => _row != null;
  bool get expired => _row != null && _expired(_row);

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
  Collection(this.db, String path)
      : path = path.endsWith('/') ? path : '$path/' {
    assert(_validPath(path), 'path "$path" must contain even number of /');
  }

  final DocumentsDao db;
  final String path;

  static bool _validPath(String path) => path.pathSeparators.isEven;

  Document doc([String? id]) => Document(db, '$path${id ?? db.db.newId}');

  Future<void> clear() => db._deleteFilter('$path%');

  Selectable<DocumentSnapshot> select({bool recursive = false}) {
    if (recursive) {
      return db
          ._getCollectionRecursive('$path%')
          .map((e) => DocumentSnapshot(Document(db, e.path), e));
    } else {
      return db
          ._getCollection('$path%')
          .map((e) => DocumentSnapshot(Document(db, e.path), e));
    }
  }

  Future<List<DocumentSnapshot>> getAll({bool recursive = false}) {
    return select(recursive: recursive).get();
  }

  Stream<List<DocumentSnapshot>> watchAll({bool recursive = false}) {
    return select(recursive: recursive).watch();
  }

  Selectable<int> getCount() {
    return db._getCollectionCount('$path%');
  }

  Future<void> addAll(
    Map<String, DocumentData?> values, {
    Duration? ttl,
    DateTime? created,
    DateTime? updated,
  }) async {
    await db.batch((tx) {
      final now = DateTime.now();
      tx.insertAll(
        db.keyValue,
        [
          for (final item in values.entries)
            DocumentsCompanion.insert(
              path: item.key,
              data: item.value ?? {},
              ttl: Value.absentIfNull(ttl?.inSeconds),
              created: (created ?? now).millisecondsSinceEpoch,
              updated: (updated ?? now).millisecondsSinceEpoch,
            ),
        ],
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> removeAll(List<String> ids) {
    return db._deleteWhere(ids.map((e) => '$path$e').toList());
  }

  @override
  String toString() {
    return 'Collection($path)';
  }

  @override
  bool operator ==(Object other) {
    return other is Collection && other.path == path;
  }

  @override
  int get hashCode => path.hashCode;
}

bool _expired(Doc row) {
  final updated = row.updated;
  final ttl = row.ttl;
  if (ttl == null) return false;
  return DateTime.now().millisecondsSinceEpoch - updated > ttl;
}

extension on Doc {
  DocumentSnapshot toSnapshot(DocumentsDao db) {
    return DocumentSnapshot(Document(db, path), this);
  }
}

extension on String {
  int countChar(String char) {
    final regExp = RegExp(char);
    final count = regExp.allMatches(this).length;
    return count;
  }

  int get pathSeparators => countChar('/');
}
