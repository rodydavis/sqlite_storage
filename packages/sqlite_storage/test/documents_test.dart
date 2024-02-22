import 'dart:io';

import 'package:sqlite_async/sqlite_async.dart';
import 'package:sqlite_storage/sqlite_storage.dart';
import 'package:test/test.dart';

import 'utils/db.dart';

void main() {
  final tempDir = tempDirFor('documents');
  final tempFile = File('${tempDir.path}/test.db')..createSync(recursive: true);
  late Database db;

  setUp(() async {
    resetDir('documents');
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

  group('document', () {
    test('add', () async {
      const prefix = 'mypath/test';
      await db.documents.doc(prefix, '1').set({'name': 'one'});
      await db.documents.doc(prefix, '2').set({'name': 'two'});
      final results = await db.documents
          .collection(prefix)
          .select()
          .get()
          .then((value) => value.map((e) => e.data).toList());
      expect(results, [
        {'name': 'one'},
        {'name': 'two'},
      ]);
    });

    test('update', () async {
      const prefix = 'mypath/test';
      await db.documents.doc(prefix, '1').set({'name': 'one', 'age': 1});
      await db.documents.doc(prefix, '1').update({'name': 'two'});
      final results = await db.documents
          .collection(prefix)
          .select()
          .get()
          .then((value) => value.map((e) => e.data).toList());
      expect(results, [
        {'name': 'two', 'age': 1},
      ]);
    });

    test('remove', () async {
      const prefix = 'mypath/test';
      await db.documents.doc(prefix, '1').set({'name': 'one'});
      await db.documents.doc(prefix, '2').set({'name': 'two'});
      await db.documents.doc(prefix, '1').remove();
      final results = await db.documents
          .collection(prefix)
          .select()
          .get()
          .then((value) => value.map((e) => e.data).toList());
      expect(results, [
        {'name': 'two'},
      ]);
    });

    test('clear', () async {
      const prefix = 'mypath/test';
      await db.documents.doc(prefix, '1').set({'name': 'one'});
      await db.documents.doc(prefix, '2').set({'name': 'two'});
      await db.documents.collection(prefix).clear();
      final results = await db.documents
          .collection(prefix)
          .select()
          .get()
          .then((value) => value.map((e) => e.data).toList());
      expect(results, []);
    });

    test('watchAll', () async {
      const prefix = 'mypath/test';
      final stream = db.documents.select().watch();
      final results = <List<DocumentSnapshot>>[];
      stream.listen(results.add);
      await db.documents.doc(prefix, '1').set({'name': 'one'});
      await Future.delayed(const Duration(milliseconds: 100));
      await db.documents.doc(prefix, '2').set({'name': 'two'});
      await Future.delayed(const Duration(milliseconds: 100));
      expect(results.map((r) => r.map((e) => e.data).toList()).toList(), [
        [
          {'name': 'one'},
        ],
        [
          {'name': 'one'},
          {'name': 'two'},
        ],
      ]);
    });

    test('watch', () async {
      const prefix = 'mypath/test';
      final stream = db.documents.doc(prefix, '1').watch();
      final results = <DocumentSnapshot>[];
      stream.listen(results.add);
      await db.documents.doc(prefix, '1').set({'name': 'one'});
      await Future.delayed(const Duration(milliseconds: 100));
      expect(results.map((e) => e.data).toList(), [
        {'name': 'one'},
      ]);
    });

    test('getAll', () async {
      await db.documents.doc('a', '1').set({'name': 'one'});
      await db.documents.doc('b', '2').set({'name': 'two'});
      final results = await db.documents
          .select()
          .get()
          .then((value) => value.map((e) => e.data).toList());
      expect(results, [
        {'name': 'one'},
        {'name': 'two'},
      ]);
    });

    test('watchAll', () async {
      final stream = db.documents.select().watch();
      final results = <List<DocumentSnapshot>>[];
      stream.listen(results.add);
      await db.documents.doc('a', '1').set({'name': 'one'});
      await Future.delayed(const Duration(milliseconds: 100));
      await db.documents.doc('b', '2').set({'name': 'two'});
      await Future.delayed(const Duration(milliseconds: 100));
      expect(results.map((r) => r.map((e) => e.data).toList()).toList(), [
        [
          {'name': 'one'},
        ],
        [
          {'name': 'one'},
          {'name': 'two'},
        ],
      ]);
    });

    test('clear', () async {
      await db.documents.doc('a', '1').set({'name': 'one'});
      await db.documents.doc('b', '2').set({'name': 'two'});
      await db.documents.clear();
      final results = await db.documents
          .select()
          .get()
          .then((value) => value.map((e) => e.data).toList());
      expect(results, []);
    });

    test('query', () async {
      await db.documents.doc('a', '1').set({'name': 'one'});
      await db.documents.doc('b', '2').set({'name': 'two'});
      final results = await db.documents
          .query('two')
          .get()
          .then((value) => value.map((e) => e.data).toList());
      expect(results, [
        {'name': 'two'},
      ]);
    });

    test('ttl', () async {
      final doc = db.documents.doc('a', '1');
      await doc.set({'name': 'one'});
      await doc.setTTl(const Duration(milliseconds: 100));
      await Future.delayed(const Duration(milliseconds: 200));
      final results = await db.documents
          .select()
          .get()
          .then((value) => value.map((e) => e.data).toList());
      expect(results, []);
    });

    test('new id', () async {
      final col = db.documents.collection('a');
      final doc = col.doc();
      await doc.set({'name': 'one'});

      expect(doc.id.isNotEmpty, true);
    });

    // group('json functions', () {
    //   test('json_extract', () async {
    //     final col = db.documents.collection('a');
    //     col.doc('1').set({'name': 'one', 'age': 1});
    //     col.doc('2').set({'name': 'two', 'age': 2});
    //     final results = await db.documents.jsonExtract(['name']).get();
    //     expect(results, ['one', 'two']);
    //   });
    // });
  });
}
