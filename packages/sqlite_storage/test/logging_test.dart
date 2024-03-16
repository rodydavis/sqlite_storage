import 'package:sqlite_storage/src/database.dart';
import 'package:test/test.dart';

import 'utils/db.dart';

void main() {
  late DriftStorage db;

  setUp(() async {
    resetDir('logging');
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
