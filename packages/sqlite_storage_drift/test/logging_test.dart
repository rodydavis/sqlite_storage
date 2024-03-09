import 'dart:io';

import 'package:sqlite_storage_drift/src/database.dart';
import 'package:test/test.dart';

import 'utils/db.dart';

void main() {
  final tempDir = tempDirFor('logging');
  final tempFile = File('${tempDir.path}/test.db')..createSync(recursive: true);
  late DriftStorage db;

  setUp(() async {
    resetDir('logging');
    tempFile.createSync(recursive: true);
    db = DriftStorage(connection());
  });

  tearDown(() async {
    await db.close();
  });

  group('logging', () {
    test('log', () async {
      await db.log.log('hello world');

      final all = await db.log.getAll();

      expect(all.map((e) => e.message).toList(), ['hello world']);
    });

    test('query', () async {
      await db.log.log('hello world', level: 1);

      final resultsA = await db.log.getSearch('hello');
      final resultsB = await db.log.getSearch('apple');

      expect(resultsA, isNotEmpty);
      expect(resultsB, isEmpty);
    });
  });
}
