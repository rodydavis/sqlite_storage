import 'dart:convert';
import 'dart:developer';

import 'package:drift/drift.dart';

import 'converters.dart';
import 'daos/analytics.dart';
import 'daos/documents.dart';
import 'daos/files.dart';
import 'daos/graph.dart';
import 'daos/key_value.dart';
import 'daos/logging.dart';
import 'daos/requests.dart';
import 'id_generator.dart';

part 'database.g.dart';

@DriftDatabase(daos: [
  KeyValueDao,
  DocumentsDao,
  FilesDao,
  AnalyticsDao,
  GraphDao,
  LoggingDao,
  RequestsDao,
], include: {
  'sql/tables.drift'
})
class DriftStorage extends _$DriftStorage {
  final String? debugLabel;

  DriftStorage(
    super.e, {
    IdGenerator? idGenerator,
    this.debugLabel,
  }) : _idGenerator = idGenerator ?? UuidGenerator() {
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
        final result = await db
            .customSelect(
              sql,
              variables: args.map(Variable.new).toList(),
            )
            .get();
        return ServiceExtensionResponse.result(jsonEncode({
          'columns': result.columns,
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
        final result = await db
            .customSelect(
              sql,
              variables: args.map(Variable.new).toList(),
            )
            .get();
        return ServiceExtensionResponse.result(jsonEncode({
          'result': result.map((e) => e.data).toList(),
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

  final IdGenerator _idGenerator;

  /// Generate new id for String based ids
  String get newId => _idGenerator();
  late final String deviceId = newId;

  @override
  int get schemaVersion => 1;

  KeyValueDao get kv => keyValueDao;
  DocumentsDao get docs => documentsDao;
  FilesDao get io => filesDao;
  LoggingDao get log => loggingDao;
  GraphDao get graph => graphDao;
  AnalyticsDao get track => analyticsDao;
  RequestsDao get http => requestsDao;

  static bool _initialized = false;
  static final _instances = <DriftStorage>[];
  static DriftStorage? instance;

  @override
  Future<void> close() {
    _instances.remove(this);
    instance = _instances.firstOrNull;
    return super.close();
  }

  (DriftStorage?, int) _getDb(Map<String, String> params) {
    final index =
        params.containsKey('index') ? int.parse(params['index'] as String) : -1;
    if (index == -1 || index < 0 || index >= _instances.length) {
      return (instance, -1);
    }
    return (_instances[index], index);
  }
}

extension on List<QueryRow> {
  List<String> get columns {
    if (isNotEmpty) return first.data.keys.toList();
    return [];
  }

  List<List<Object?>> get rows {
    final results = <List<Object?>>[];
    for (final item in this) {
      results.add(item.data.values.toList());
    }
    return results;
  }
}
