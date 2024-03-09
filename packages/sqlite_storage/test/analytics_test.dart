import 'dart:io';

import 'package:sqlite_storage/src/database.dart';
import 'package:test/test.dart';

import 'utils/db.dart';

void main() {
  final tempDir = tempDirFor('analytics');
  final tempFile = File('${tempDir.path}/test.db')..createSync(recursive: true);
  late DriftStorage db;

  setUp(() async {
    resetDir('analytics');
    tempFile.createSync(recursive: true);
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
