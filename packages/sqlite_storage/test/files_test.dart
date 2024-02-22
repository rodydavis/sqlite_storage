import 'dart:io';

import 'package:sqlite_async/sqlite_async.dart';
import 'package:sqlite_storage/sqlite_storage.dart';
import 'package:test/test.dart';

import 'utils/db.dart';

void main() {
  final tempDir = tempDirFor('files');
  final tempFile = File('${tempDir.path}/test.db')..createSync(recursive: true);
  late Database db;

  setUp(() async {
    resetDir('files');
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

  group('files', () {
    test('write and read', () async {
      const path = 'mypath/test';
      await db.files.writeAsString(path, 'hello');
      final result = await db.files.readAsString(path);
      expect(result, 'hello');
    });

    test('exists', () async {
      const path = 'mypath/test';
      await db.files.writeAsString(path, 'hello');
      final result = await db.files.exists(path);
      expect(result, isTrue);
    });

    test('metadata', () async {
      const path = 'mypath/test';
      await db.files.writeAsString(path, 'hello');
      final result = await db.files.metadata(path);
      expect(result.created, isA<DateTime>());
      expect(result.updated, isA<DateTime>());
    });

    test('watch', () async {
      const path = 'mypath/test';
      final events = <String?>[];
      db.files.watchAsString(path).listen(events.add);
      await db.files.writeAsString(path, 'hello');
      await Future.delayed(const Duration(milliseconds: 100));
      await db.files.writeAsString(path, 'world');
      await Future.delayed(const Duration(milliseconds: 100));
      expect(events, ['hello', 'world']);
    });

    test('remove', () async {
      const path = 'mypath/test';
      await db.files.writeAsString(path, 'hello');
      await db.files.delete(path);
      final result = await db.files.exists(path);
      expect(result, isFalse);
    });

    group('string', () {
      test('read', () async {
        const path = 'mypath/test';
        await db.files.writeAsString(path, 'hello');
        final result = await db.files.readAsString(path);
        expect(result, 'hello');
      });

      test('write', () async {
        const path = 'mypath/test';
        await db.files.writeAsString(path, 'hello');
        final result = await db.files.readAsString(path);
        expect(result, 'hello');
      });

      test('watch', () async {
        const path = 'mypath/test';
        final events = <String?>[];
        db.files.watchAsString(path).listen(events.add);
        await db.files.writeAsString(path, 'hello');
        await Future.delayed(const Duration(milliseconds: 100));
        await db.files.writeAsString(path, 'world');
        await Future.delayed(const Duration(milliseconds: 100));
        expect(events, ['hello', 'world']);
      });
    });

    group('bytes', () {
      test('read', () async {
        const path = 'mypath/test';
        await db.files.writeAsBytes(path, [1, 2, 3]);
        final result = await db.files.readAsBytes(path);
        expect(result, [1, 2, 3]);
      });

      test('write', () async {
        const path = 'mypath/test';
        await db.files.writeAsBytes(path, [1, 2, 3]);
        final result = await db.files.readAsBytes(path);
        expect(result, [1, 2, 3]);
      });

      test('watch', () async {
        const path = 'mypath/test';
        final events = <List<int>?>[];
        db.files.watchAsBytes(path).listen(events.add);
        await db.files.writeAsBytes(path, [1, 2, 3]);
        await Future.delayed(const Duration(milliseconds: 100));
        await db.files.writeAsBytes(path, [4, 5, 6]);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(events, [
          [1, 2, 3],
          [4, 5, 6],
        ]);
      });
    });
  });
}
