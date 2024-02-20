import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';

extension DatabaseUtils on SqliteDatabase {
  Selectable<T> select<T>(
    String sql, {
    List<Object?> args = const [],
    required T Function(Row) mapper,
  }) {
    return Selectable<T>(
      this,
      sql,
      args,
      mapper: mapper,
    );
  }
}

class Selectable<T> {
  final SqliteDatabase db;
  final String sql;
  final List<Object?> args;
  final T Function(Row) mapper;

  Selectable(
    this.db,
    this.sql,
    this.args, {
    required this.mapper,
  });

  Future<T> getSingle() async {
    final item = await db.get(sql, args);
    return mapper(item);
  }

  Future<T?> getSingleOrNull() async {
    final item = await db.getOptional(sql, args);
    return item == null ? null : mapper(item);
  }

  Future<List<T>> get() async {
    final items = await db.getAll(sql, args);
    return items.map(mapper).toList();
  }

  Stream<List<T>> watch({
    Duration throttle = const Duration(milliseconds: 30),
  }) async* {
    final stream = db.watch(sql, parameters: args, throttle: throttle);
    await for (final results in stream) {
      yield results.map(mapper).toList();
    }
  }

  Stream<T?> watchSingleOrNull({
    Duration throttle = const Duration(milliseconds: 30),
  }) async* {
    final stream = db.watch(sql, parameters: args, throttle: throttle);
    await for (final results in stream) {
      yield results.isEmpty ? null : mapper(results.first);
    }
  }

  Stream<T> watchSingle({
    Duration throttle = const Duration(milliseconds: 30),
  }) async* {
    final stream = db.watch(sql, parameters: args, throttle: throttle);
    await for (final results in stream) {
      yield mapper(results.first);
    }
  }
}
