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
  DriftStorage(super.e, {IdGenerator? idGenerator})
      : _idGenerator = idGenerator ?? UuidGenerator();

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
}
