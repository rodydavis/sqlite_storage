import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';

extension DatabaseUtils on SqliteDatabase {
  Selectable<T> select<T>(
    String sql, {
    List<Object?> args = const [],
    required T Function(Row) mapper,
    List<String>? tables,
  }) {
    return Selectable<T>(
      this,
      sql,
      args,
      mapper: mapper,
      tables: tables,
    );
  }
}

class Selectable<T> {
  final SqliteDatabase db;
  final String sql;
  final List<Object?> args;
  final T Function(Row) mapper;
  final List<String>? tables;

  Selectable(
    this.db,
    this.sql,
    this.args, {
    required this.mapper,
    this.tables,
  });

  Future<T> getSingle() async {
    final item = await db.get(sql, args);
    return mapper(item);
  }

  Future<T?> getSingleOrNull() async {
    final item = await db.getOptional(sql, args);
    return item == null ? null : mapper(item);
  }

  Stream<T?> watchSingleOrNull({
    Duration throttle = const Duration(milliseconds: 30),
  }) async* {
    final stream = db.watch(
      sql,
      parameters: args,
      throttle: throttle,
      triggerOnTables: tables,
    );
    await for (final results in stream) {
      yield results.isEmpty ? null : mapper(results.first);
    }
  }

  Stream<T> watchSingle({
    Duration throttle = const Duration(milliseconds: 30),
  }) async* {
    final stream = db.watch(
      sql,
      parameters: args,
      throttle: throttle,
      triggerOnTables: tables,
    );
    await for (final results in stream) {
      yield mapper(results.first);
    }
  }

  Future<List<T>> get({
    int? limit,
    int? offset,
  }) async {
    final sb = StringBuffer(
      sql.endsWith(';') ? sql.substring(0, sql.length - 1) : sql,
    );
    if (limit != null) {
      sb.write(' LIMIT :limit');
    }
    if (offset != null) {
      sb.write(' OFFSET :offset');
    }
    final items = await db.getAll(sb.toString(), [
      ...args.toList(),
      if (limit != null) limit,
      if (offset != null) offset,
    ]);
    return items.map(mapper).toList();
  }

  Stream<List<T>> watch({
    int? limit,
    int? offset,
    Duration throttle = const Duration(milliseconds: 30),
  }) async* {
    final sb = StringBuffer(
      sql.endsWith(';') ? sql.substring(0, sql.length - 1) : sql,
    );
    if (limit != null) {
      sb.write(' LIMIT :limit');
    }
    if (offset != null) {
      sb.write(' OFFSET :offset');
    }
    final stream = db.watch(
      sb.toString(),
      parameters: [
        ...args.toList(),
        if (limit != null) limit,
        if (offset != null) offset,
      ],
      throttle: throttle,
      triggerOnTables: tables,
    );
    await for (final results in stream) {
      yield results.map(mapper).toList();
    }
  }
}
