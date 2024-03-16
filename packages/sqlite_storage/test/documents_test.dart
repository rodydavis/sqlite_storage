import 'package:sqlite_storage/src/daos/documents.dart';
import 'package:sqlite_storage/src/database.dart';
import 'package:test/test.dart';

import 'utils/db.dart';

void main() {
  late DriftStorage db;

  setUp(() async {
    resetDir('docs');
    db = DriftStorage(connection());
  });

  tearDown(() async {
    await db.close();
  });

  group('document', () {
    test('add', () async {
      const prefix = 'mypath/1/test';
      await db.docs.doc(prefix, '1').set({'name': 'one'});
      await db.docs.doc(prefix, '2').set({'name': 'two'});
      final results = await db.docs
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
      const prefix = 'mypath/1/test';
      await db.docs.doc(prefix, '1').set({'name': 'one', 'age': 1});
      await db.docs.doc(prefix, '1').update({'name': 'two'});
      final results = await db.docs
          .collection(prefix)
          .select()
          .get()
          .then((value) => value.map((e) => e.data).toList());
      expect(results, [
        {'name': 'two', 'age': 1},
      ]);
    });

    test('remove', () async {
      const prefix = 'mypath/1/test';
      await db.docs.doc(prefix, '1').set({'name': 'one'});
      await db.docs.doc(prefix, '2').set({'name': 'two'});
      await db.docs.doc(prefix, '1').remove();
      final results = await db.docs
          .collection(prefix)
          .select()
          .get()
          .then((value) => value.map((e) => e.data).toList());
      expect(results, [
        {'name': 'two'},
      ]);
    });

    test('clear', () async {
      const prefix = 'mypath/1/test';
      await db.docs.doc(prefix, '1').set({'name': 'one'});
      await db.docs.doc(prefix, '2').set({'name': 'two'});
      await db.docs.collection(prefix).clear();
      final results = await db.docs
          .collection(prefix)
          .select()
          .get()
          .then((value) => value.map((e) => e.data).toList());
      expect(results, []);
    });

    test('watchAll', () async {
      const prefix = 'mypath/1/test';
      final stream = db.docs.getAll().watch();
      final results = <List<DocumentSnapshot>>[];
      stream.listen(results.add);
      await db.docs.doc(prefix, '1').set({'name': 'one'});
      await Future.delayed(const Duration(milliseconds: 100));
      await db.docs.doc(prefix, '2').set({'name': 'two'});
      await Future.delayed(const Duration(milliseconds: 100));
      expect(results.map((r) => r.map((e) => e.data).toList()).toList(), [
        [],
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
      const prefix = 'mypath/1/test';
      final stream = db.docs.doc(prefix, '1').select().watchSingleOrNull();
      final results = <DocumentSnapshot?>[];
      stream.listen(results.add);
      await db.docs.doc(prefix, '1').set({'name': 'one'});
      await Future.delayed(const Duration(milliseconds: 100));
      expect(results.map((e) => e?.data).toList(), [
        null,
        {'name': 'one'},
      ]);
    });

    test('getAll', () async {
      await db.docs.doc('a', '1').set({'name': 'one'});
      await db.docs.doc('b', '2').set({'name': 'two'});
      final results = await db.docs
          .getAll()
          .get()
          .then((value) => value.map((e) => e.data).toList());
      expect(results, [
        {'name': 'one'},
        {'name': 'two'},
      ]);
    });

    test('watchAll', () async {
      final stream = db.docs.getAll().watch();
      final results = <List<DocumentSnapshot>>[];
      stream.listen(results.add);
      await db.docs.doc('a', '1').set({'name': 'one'});
      await Future.delayed(const Duration(milliseconds: 100));
      await db.docs.doc('b', '2').set({'name': 'two'});
      await Future.delayed(const Duration(milliseconds: 100));
      expect(results.map((r) => r.map((e) => e.data).toList()).toList(), [
        [],
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
      await db.docs.doc('a', '1').set({'name': 'one'});
      await db.docs.doc('b', '2').set({'name': 'two'});
      await db.docs.clear();
      final results = await db.docs
          .getAll()
          .get()
          .then((value) => value.map((e) => e.data).toList());
      expect(results, []);
    });

    test('query', () async {
      await db.docs.doc('a', '1').set({'name': 'one'});
      await db.docs.doc('b', '2').set({'name': 'two'});
      final results = await db.docs
          .search('two')
          .get()
          .then((value) => value.map((e) => e.data).toList());
      expect(results, [
        {'name': 'two'},
      ]);
    });

    test('paging', () async {
      final col = db.docs.collection('a');
      for (var i = 0; i < 100; i++) {
        await col.doc('$i').set({'name': 'node $i'});
      }

      final count = await col.getCount().getSingleOrNull();
      expect(count, 100);

      // final results = await col.select().get(limit: 10);
      // expect(results.length, 10);
    });

    test('ttl', () async {
      final doc = db.docs.doc('a', '1');
      await doc.set({'name': 'one'});
      await doc.setTTl(const Duration(milliseconds: 100));
      await Future.delayed(const Duration(milliseconds: 200));
      final results = await db.docs
          .getAll()
          .get()
          .then((value) => value.map((e) => e.data).toList());
      expect(results, []);
    });

    test('new id', () async {
      final col = db.docs.collection('a');
      final doc = col.doc();
      await doc.set({'name': 'one'});

      expect(doc.id.isNotEmpty, true);
    });

    test('paths', () async {
      final paths = {
        'users:1',
        'users/1/comments:2',
        'posts/1/comments:2',
        'posts/1/comments:3',
        'posts:1',
        'posts/1/info:1',
        'users:2',
      };
      for (final item in paths) {
        final [path, id] = item.split(':');
        final file = db.docs.doc(path, id);
        await file.set({});
      }

      final postsDir = db.docs.collection('posts');
      final posts1Dir = postsDir.doc('1').collection('comments');
      final dir = await db.docs.getAll().get();

      expect(dir.length, paths.length);

      final postsDirDocs = await postsDir.getAll();
      final postsDirDocsR = await postsDir.getAll(recursive: true);

      expect(postsDirDocs.length, 1);
      expect(postsDirDocsR.length, 4);

      final posts1DirDocs = await posts1Dir.getAll();

      expect(posts1DirDocs.length, 2);
    });

    group('json functions', () {
      test('json_extract', () async {
        final col = db.docs.collection('a');
        col.doc('1').set({'name': 'one', 'age': 1});
        col.doc('2').set({'name': 'two', 'age': 2});

        final results = await db.docs.query().get();
        expect(results.length, 2);

        final results2 = await db.docs.query(pathEquals: 'a/1').get();
        expect(results2.length, 1);

        final results3 = await db.docs
            .query(
              filters: CompareFilter(
                JsonField('age'),
                QueryOperator.greaterThan,
                LiteralValue(1),
              ),
            )
            .get();
        expect(results3.length, 1);
      });
    });
  });
}
