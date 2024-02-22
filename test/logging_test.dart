import 'dart:io';

import 'package:sqlite_async/sqlite_async.dart';
import 'package:sqlite_storage/sqlite_storage.dart';
import 'package:test/test.dart';

import 'utils/db.dart';

void main() {
  final tempDir = tempDirFor('logging');
  final tempFile = File('${tempDir.path}/test.db')..createSync(recursive: true);
  late Database db;

  setUp(() async {
    resetDir('logging');
    tempFile.createSync(recursive: true);
    db = Database(SqliteDatabase(
      path: tempFile.path,
      options: const SqliteOptions(journalMode: SqliteJournalMode.wal),
    ));
    await db.open();
    await Future.delayed(const Duration(milliseconds: 100));
  });

  tearDown(() async {
    await db.close();
  });

  group('logging', () {
    test('log', () async {
      await db.logging.log('hello world');

      final all = await db.logging.select().get();

      expect(all.map((e) => e.message).toList(), ['hello world']);
    });

    test('query', () async {
      final queryA = const LogsQuery() //
          .level(1);
      final queryB = const LogsQuery() //
          .levelGreaterThan(1);
      await db.logging.log('hello world', level: 1);

      final resultsA = await db.logging.query(queryA).get();
      final resultsB = await db.logging.query(queryB).get();

      expect(resultsA, isNotEmpty);
      expect(resultsB, isEmpty);
    });
  });
}
