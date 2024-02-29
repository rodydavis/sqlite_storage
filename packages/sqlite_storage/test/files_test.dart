import 'dart:convert';
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
      final file = DatabaseFile(db.files, path);
      await file.writeAsString('hello');
      final result = await file.readAsString();
      expect(result, 'hello');
    });

    test('2 files', () async {
      final dir = DatabaseDirectory(db.files, 'test');

      // expect(await dir.exists(), false);

      final fileA = dir.file('a.txt');
      await fileA.writeAsString('A');

      final fileB = dir.file('b.txt');
      await fileB.writeAsString('B');

      expect(await dir.exists(), true);
      expect((await dir.list(recursive: true)).length, 2);
      expect((await dir.list(recursive: false)).length, 2);
    });

    test('exists', () async {
      const path = 'mypath/test';
      final file = DatabaseFile(db.files, path);
      await file.writeAsString('hello');
      final result = await file.exists();
      expect(result, isTrue);
    });

    test('metadata', () async {
      const path = 'mypath/test.txt';
      const raw = 'hello';
      final file = DatabaseFile(db.files, path);
      await file.writeAsString(raw);
      final result = await file.metadata();
      expect(result.created, isA<DateTime>());
      expect(result.updated, isA<DateTime>());
      expect(result.size, utf8.encode(raw).length);
      expect(result.mimeType, 'text/plain');
    });

    test('watch', () async {
      const path = 'mypath/test';
      final events = <String?>[];
      final file = DatabaseFile(db.files, path);
      file.watchAsString().listen(events.add);
      await Future.delayed(const Duration(milliseconds: 100));
      await file.writeAsString('hello');
      await Future.delayed(const Duration(milliseconds: 100));
      await file.writeAsString('world');
      await Future.delayed(const Duration(milliseconds: 100));
      expect(events, [null, 'hello', 'world']);
    });

    test('remove', () async {
      const path = 'mypath/test';
      final file = DatabaseFile(db.files, path);
      await file.writeAsString('hello');
      await file.delete();
      final result = await file.exists();
      expect(result, isFalse);
    });

    group('string', () {
      test('read', () async {
        const path = 'mypath/test';
        final file = DatabaseFile(db.files, path);
        await file.writeAsString('hello');
        final result = await file.readAsString();
        expect(result, 'hello');
      });

      test('write', () async {
        const path = 'mypath/test';
        final file = DatabaseFile(db.files, path);
        await file.writeAsString('hello');
        final result = await file.readAsString();
        expect(result, 'hello');
      });

      test('watch', () async {
        const path = 'mypath/test';
        final events = <String?>[];
        final file = DatabaseFile(db.files, path);
        file.watchAsString().listen(events.add);
        await Future.delayed(const Duration(milliseconds: 100));
        await file.writeAsString('hello');
        await Future.delayed(const Duration(milliseconds: 100));
        await file.writeAsString('world');
        await Future.delayed(const Duration(milliseconds: 100));
        expect(events, [null, 'hello', 'world']);
      });
    });

    group('bytes', () {
      test('read', () async {
        const path = 'mypath/test';
        final file = DatabaseFile(db.files, path);
        await file.writeAsBytes([1, 2, 3]);
        final result = await file.readAsBytes();
        expect(result, [1, 2, 3]);
      });

      test('write', () async {
        const path = 'mypath/test';
        final file = DatabaseFile(db.files, path);
        await file.writeAsBytes([1, 2, 3]);
        final result = await file.readAsBytes();
        expect(result, [1, 2, 3]);
      });

      test('watch', () async {
        const path = 'mypath/test.txt';
        final events = <List<int>?>[];
        final file = DatabaseFile(db.files, path);
        file.watchAsBytes().listen(events.add);
        await file.writeAsBytes([1, 2, 3]);
        await Future.delayed(const Duration(milliseconds: 100));
        await file.writeAsBytes([4, 5, 6]);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(events, [
          null,
          [1, 2, 3],
          [4, 5, 6],
        ]);
      });
    });
  });
}
