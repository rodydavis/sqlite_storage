import 'dart:io';

import 'package:sqlite_async/sqlite_async.dart';
import 'package:sqlite_storage/sqlite_storage.dart';
import 'package:test/test.dart';

import 'utils/db.dart';

void main() {
  final tempDir = tempDirFor('analytics');
  final tempFile = File('${tempDir.path}/test.db')..createSync(recursive: true);
  late Database db;

  setUp(() async {
    resetDir('analytics');
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

  group('analytics', () {
    test('sendEvent', () async {
      await db.analytics.sendEvent('event', 'test');

      final all = await db.analytics.select().get();

      expect(all.map((e) => e.type).toList(), ['event']);
    });
  });
}
