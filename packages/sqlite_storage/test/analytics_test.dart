import 'package:sqlite_storage/src/database.dart';
import 'package:test/test.dart';

import 'utils/db.dart';

void main() {
  late DriftStorage db;

  setUp(() async {
    resetDir('analytics');
    db = DriftStorage(connection());
  });

  tearDown(() async {
    await db.close();
  });

  group('analytics', () {
    test('sendEvent', () async {
      await db.track.sendEvent('event', 'test');

      final all = await db.track.getAll();

      expect(all.map((e) => e.type).toList(), ['event']);
    });
  });
}
