// ignore_for_file: public_member_api_docs, sort_constructors_first
library sqlite_storage;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:http/http.dart' as http;

import '../analytics.dart';
import '../files.dart';
import '../graph.dart';
import '../key_value.dart';
import '../documents.dart';
import '../logging.dart';
import '../requests.dart';
import 'selectable.dart';

class Database {
  Database(this.db, [this.debugLabel]);
  final SqliteDatabase db;
  final String? debugLabel;
  http.Client innerClient = http.Client();

  late final kv = KeyValueDatabase(this);
  late final documents = DocumentDatabase(this);
  late final files = FilesDatabase(this);
  late final graph = GraphDatabase(this);
  late final logging = LoggingDatabase(this);
  late final analytics = AnalyticsDatabase(this);
  late final requests = RequestsDatabase(this, innerClient);

  static bool _initialized = false;
  static final _instances = <Database>[];
  static Database? instance;

  List<Dao> get daos => [
        kv,
        documents,
        files,
        graph,
        logging,
        analytics,
        requests,
      ];

  Future<void> open() async {
    final migrations = SqliteMigrations();
    migrations.add(SqliteMigration(
      1,
      (tx) async {
        for (final dao in daos) {
          dao.migrate(1, tx, false);
        }
      },
    ));
    await migrations.migrate(db);
    for (final dao in daos) {
      await dao.open();
    }
    _instances.add(this);
    instance = this;
    if (!_initialized) {
      registerExtension(
        'ext.sqlite_storage.getDatabases',
        (method, params) async {
          return ServiceExtensionResponse.result(jsonEncode({
            'databases': [
              for (var i = 0; i < _instances.length; i++)
                _instances[i].debugLabel ?? 'Database #$i',
            ],
          }));
        },
      );
      registerExtension(
        'ext.sqlite_storage.getDatabase',
        (method, params) async {
          final (db, index) = _getDb(params);
          if (db == null) {
            return ServiceExtensionResponse.error(
              400,
              'Database not found',
            );
          }
          return ServiceExtensionResponse.result(jsonEncode({
            'database': db.debugLabel ?? 'Database #$index',
          }));
        },
      );
      registerExtension('ext.sqlite_storage.setDatabase',
          (method, params) async {
        final (db, index) = _getDb(params);
        if (db == null) {
          return ServiceExtensionResponse.error(
            400,
            'Database not found',
          );
        }
        instance = _instances[index];
        return ServiceExtensionResponse.result(jsonEncode({}));
      });
      registerExtension('ext.sqlite_storage.executeSql',
          (method, params) async {
        final (db, _) = _getDb(params);
        if (db == null) {
          return ServiceExtensionResponse.error(
            400,
            'Database not found',
          );
        }
        final sql = params['sql'] as String;
        final args = jsonDecode(params['args'] as String) as List<Object?>;
        final result = await db.db.execute(sql, args);
        return ServiceExtensionResponse.result(jsonEncode({
          'columns': result.columnNames,
          'rows': result.rows,
        }));
      });
      registerExtension('ext.sqlite_storage.getSql', (method, params) async {
        final (db, _) = _getDb(params);
        if (db == null) {
          return ServiceExtensionResponse.error(
            400,
            'Database not found',
          );
        }
        final sql = params['sql'] as String;
        final args = jsonDecode(params['args'] as String) as List<Object?>;
        final result = await db.db.get(sql, args);
        return ServiceExtensionResponse.result(jsonEncode({
          'result': result,
        }));
      });
      registerExtension('ext.sqlite_storage.getGraphData',
          (method, parameters) async {
        final (db, _) = _getDb(parameters);
        if (db == null) {
          return ServiceExtensionResponse.error(
            400,
            'Database not found',
          );
        }
        final result = await db.graph.getGraphData();
        return ServiceExtensionResponse.result(jsonEncode({
          'nodes': result.nodes
              .map((e) => {
                    'id': e.id,
                    'label': e.label,
                  })
              .toList(),
          'edges': result.edges
              .map((e) => {
                    'from': e.from,
                    'to': e.to,
                  })
              .toList(),
        }));
      });
      // registerExtension('ext.sqlite_storage.getKv', (method, params) async {
      //   final (db, _) = _getDb(params);
      //   if (db == null) {
      //     return ServiceExtensionResponse.error(
      //       400,
      //       'Database not found',
      //     );
      //   }
      //   final result = await db.kv.getAll();
      //   return ServiceExtensionResponse.result(jsonEncode({
      //     'data': result,
      //   }));
      // });
      _initialized = true;
    }
  }

  Future<void> close() async {
    for (final dao in daos) {
      await dao.close();
    }
    await db.close();
    _instances.remove(this);
    instance = _instances.firstOrNull;
  }

  Selectable<T?> query<T>(
    String table, {
    String where = '',
    List<Object?> whereArgs = const [],
    List<String> columns = const [],
    required T? Function(Row) mapper,
  }) {
    final sql = StringBuffer(
      'SELECT ${columns.isEmpty ? '*' : columns.join(',')} FROM $table',
    );
    final args = [...whereArgs];
    if (where.isNotEmpty) {
      sql.write(' WHERE $where');
    }
    return db.select(sql.toString(), args: args, mapper: mapper);
  }

  (Database?, int) _getDb(Map<String, String> params) {
    final index =
        params.containsKey('index') ? int.parse(params['index'] as String) : -1;
    if (index == -1 || index < 0 || index >= _instances.length) {
      return (instance, -1);
    }
    return (_instances[index], index);
  }
}

abstract class Dao {
  final Database database;
  Dao(this.database);

  Future<void> migrate(int toVersion, SqliteWriteContext tx, bool down);

  Future<void> open() async {}

  Future<void> close() async {}
}
