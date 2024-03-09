import 'dart:io';

import 'package:sqlite_async/sqlite_async.dart';
import 'package:sqlite_storage/sqlite_storage.dart';
import 'package:test/test.dart';

import 'utils/db.dart';

void main() {
  final tempDir = tempDirFor('kv');
  final tempFile = File('${tempDir.path}/test.db')..createSync(recursive: true);
  late Database db;

  setUp(() async {
    resetDir('kv');
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

  group('key_value', () {
    group('string', () {
      test('setString', () async {
        await db.kv.setString('key', 'value');
        expect(await db.kv.getString('key'), 'value');
      });

      test('getString', () async {
        await db.kv.set('key', 'value');
        expect(await db.kv.getString('key'), 'value');
      });

      test('watchString', () async {
        final list = <String?>[];
        final watch = db.kv.watchString('key');
        watch.listen(list.add);
        await db.kv.set('key', 'value');
        await Future.delayed(const Duration(milliseconds: 100));
        await db.kv.set('key', 'value2');
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, ['value', 'value2']);
      });

      test('getString missing', () async {
        expect(await db.kv.getString('key'), null);
      });

      test('getString wrong type', () async {
        await db.kv.set('key', 42);
        expect(
          () async => await db.kv.getString('key'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('int', () {
      test('setInt', () async {
        await db.kv.setInt('key', 42);
        expect(await db.kv.getInt('key'), 42);
      });
      test('getInt', () async {
        await db.kv.set('key', 42);
        expect(await db.kv.getInt('key'), 42);
      });

      test('watchInt', () async {
        final list = <int?>[];
        final watch = db.kv.watchInt('key');
        watch.listen(list.add);
        await db.kv.set('key', 42);
        await Future.delayed(const Duration(milliseconds: 100));
        await db.kv.set('key', 43);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, [42, 43]);
      });

      test('getInt missing', () async {
        expect(await db.kv.getInt('key'), null);
      });
      test('getInt wrong type', () async {
        await db.kv.set('key', 'value');
        expect(
          () async => await db.kv.getInt('key'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('double', () {
      test('setDouble', () async {
        await db.kv.setDouble('key', 42.0);
        expect(await db.kv.getDouble('key'), 42.0);
      });
      test('getDouble', () async {
        await db.kv.set('key', 42.0);
        await db.kv.set('key2', 42);
        expect(await db.kv.getDouble('key'), 42.0);
        expect(await db.kv.getDouble('key2'), 42.0);
      });

      test('watchDouble', () async {
        final list = <double?>[];
        final watch = db.kv.watchDouble('key');
        watch.listen(list.add);
        await db.kv.set('key', 42.0);
        await Future.delayed(const Duration(milliseconds: 100));
        await db.kv.set('key', 43.0);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, [42.0, 43.0]);
      });

      test('getDouble missing', () async {
        expect(await db.kv.getDouble('key'), null);
      });
      test('getDouble wrong type', () async {
        await db.kv.set('key', 'value');
        expect(
          () async => await db.kv.getDouble('key'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('num', () {
      test('setNum', () async {
        await db.kv.setNum('key', 42);
        expect(await db.kv.getNum('key'), 42);
      });
      test('getNum', () async {
        await db.kv.set('key', 42);
        expect(await db.kv.getNum('key'), 42);
      });

      test('watchNum', () async {
        final list = <num?>[];
        final watch = db.kv.watchNum('key');
        watch.listen(list.add);
        await db.kv.set('key', 42);
        await Future.delayed(const Duration(milliseconds: 100));
        await db.kv.set('key', 43);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, [42, 43]);
      });

      test('getNum missing', () async {
        expect(await db.kv.getNum('key'), null);
      });
      test('getNum wrong type', () async {
        await db.kv.set('key', 'value');
        expect(
          () async => await db.kv.getNum('key'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('bool', () {
      test('setBool', () async {
        await db.kv.setBool('key', true);
        expect(await db.kv.getBool('key'), true);
      });
      test('getBool', () async {
        await db.kv.set('key', true);
        expect(await db.kv.getBool('key'), true);
      });

      test('watchBool', () async {
        final list = <bool?>[];
        final watch = db.kv.watchBool('key');
        watch.listen(list.add);
        await db.kv.set('key', true);
        await Future.delayed(const Duration(milliseconds: 100));
        await db.kv.set('key', false);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, [true, false]);
      });

      test('getBool missing', () async {
        expect(await db.kv.getBool('key'), null);
      });
      test('getBool wrong type', () async {
        await db.kv.set('key', 'value');
        expect(
          () async => await db.kv.getBool('key'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('enum', () {
      test('setEnum', () async {
        await db.kv.setEnum('key', TestEnum.one);
        expect(await db.kv.getEnum(TestEnum.values, 'key'), TestEnum.one);
      });
      test('getEnum', () async {
        await db.kv.setEnum('key', TestEnum.one);
        expect(await db.kv.getEnum(TestEnum.values, 'key'), TestEnum.one);
      });

      test('watchEnum', () async {
        final list = <TestEnum?>[];
        final watch = db.kv.watchEnum(TestEnum.values, 'key');
        watch.listen(list.add);
        await db.kv.setEnum('key', TestEnum.one);
        await Future.delayed(const Duration(milliseconds: 100));
        await db.kv.setEnum('key', TestEnum.two);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, [TestEnum.one, TestEnum.two]);
      });

      test('getEnum missing', () async {
        expect(await db.kv.getEnum(TestEnum.values, 'key'), null);
      });
      test('getEnum wrong type', () async {
        await db.kv.set('key', 'value');
        expect(
          () async => await db.kv.getEnum(TestEnum.values, 'key'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('date time', () {
      test('setDateTime', () async {
        final date = DateTime.now();
        await db.kv.setDateTime('key', date);
        expect(await db.kv.getDateTime('key'), date);
      });
      test('getDateTime', () async {
        final date = DateTime.now();
        await db.kv.setDateTime('key', date);
        expect(await db.kv.getDateTime('key'), date);
      });

      test('watchDateTime', () async {
        final list = <DateTime?>[];
        final watch = db.kv.watchDateTime('key');
        watch.listen(list.add);
        final date = DateTime.now();
        await db.kv.setDateTime('key', date);
        await Future.delayed(const Duration(milliseconds: 100));
        final date2 = DateTime.now();
        await db.kv.setDateTime('key', date2);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, [date, date2]);
      });

      test('getDateTime missing', () async {
        expect(await db.kv.getDateTime('key'), null);
      });
      test('getDateTime wrong type', () async {
        await db.kv.set('key', 'value');
        expect(
          () async => await db.kv.getDateTime('key'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('duration', () {
      test('setDuration', () async {
        const duration = Duration(seconds: 42);
        await db.kv.setDuration('key', duration);
        expect(await db.kv.getDuration('key'), duration);
      });

      test('getDuration', () async {
        const duration = Duration(seconds: 42);
        await db.kv.setDuration('key', duration);
        expect(await db.kv.getDuration('key'), duration);
      });

      test('watchDuration', () async {
        final list = <Duration?>[];
        final watch = db.kv.watchDuration('key');
        watch.listen(list.add);
        const duration = Duration(seconds: 42);
        await db.kv.setDuration('key', duration);
        await Future.delayed(const Duration(milliseconds: 100));
        const duration2 = Duration(seconds: 43);
        await db.kv.setDuration('key', duration2);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, [duration, duration2]);
      });

      test('getDuration missing', () async {
        expect(await db.kv.getDuration('key'), null);
      });

      test('getDuration wrong type', () async {
        await db.kv.set('key', 'value');
        expect(
          () async => await db.kv.getDuration('key'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('json map', () {
      test('setJsonMap', () async {
        await db.kv.setJsonMap('key', {'key': 'value'});
        expect(await db.kv.getJsonMap('key'), {'key': 'value'});
      });
      test('getJsonMap', () async {
        await db.kv.set('key', {'key': 'value'});
        expect(await db.kv.getJsonMap('key'), {'key': 'value'});
      });

      test('watchJsonMap', () async {
        final list = <Map<String, Object?>?>[];
        final watch = db.kv.watchJsonMap('key');
        watch.listen(list.add);
        await db.kv.set('key', {'key': 'value'});
        await Future.delayed(const Duration(milliseconds: 100));
        await db.kv.set('key', {'key': 'value2'});
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, [
          {'key': 'value'},
          {'key': 'value2'}
        ]);
      });

      test('getJsonMap missing', () async {
        expect(await db.kv.getJsonMap('key'), null);
      });
      test('getJsonMap wrong type', () async {
        await db.kv.set('key', 'value');
        expect(
          () async => await db.kv.getJsonMap('key'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('json list', () {
      test('setJsonList', () async {
        await db.kv.setJsonList('key', ['value']);
        expect(await db.kv.getJsonList('key'), ['value']);
      });
      test('getJsonList', () async {
        await db.kv.set('key', ['value']);
        await db.kv.set('key2', [
          {'key': 'value'}
        ]);
        expect(await db.kv.getJsonList('key'), ['value']);
        expect(await db.kv.getJsonList('key2'), [
          {'key': 'value'}
        ]);
      });

      test('watchJsonList', () async {
        final list = <List<Object?>?>[];
        final watch = db.kv.watchJsonList('key');
        watch.listen(list.add);
        await db.kv.set('key', ['value']);
        await Future.delayed(const Duration(milliseconds: 100));
        await db.kv.set('key', ['value2']);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, [
          ['value'],
          ['value2']
        ]);
      });

      test('getJsonList missing', () async {
        expect(await db.kv.getJsonList('key'), null);
      });
      test('getJsonList wrong type', () async {
        await db.kv.set('key', 'value');
        expect(
          () async => await db.kv.getJsonList('key'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('json', () {
      test('setJson', () async {
        await db.kv.setJson('key', {'key': 'value'});
        expect(await db.kv.getJson('key'), {'key': 'value'});
      });
      test('getJson', () async {
        await db.kv.set('key', {'key': 'value'});
        expect(await db.kv.getJson('key'), {'key': 'value'});
      });

      test('watchJson', () async {
        final list = <Object?>[];
        final watch = db.kv.watchJson('key');
        watch.listen(list.add);
        await db.kv.set('key', {'key': 'value'});
        await Future.delayed(const Duration(milliseconds: 100));
        await db.kv.set('key', {'key': 'value2'});
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, [
          {'key': 'value'},
          {'key': 'value2'}
        ]);
      });

      test('getJson missing', () async {
        expect(await db.kv.getJson('key'), null);
      });
      test('getJson wrong type', () async {
        await db.kv.set('key', 'value');
        expect(
          () async => await db.kv.getJson('key'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('bytes', () {
      test('setBytes', () async {
        await db.kv.setBytes('key', [1, 2, 3]);
        expect(await db.kv.getBytes('key'), [1, 2, 3]);
      });
      test('getBytes', () async {
        await db.kv.set('key', [1, 2, 3]);
        expect(await db.kv.getBytes('key'), [1, 2, 3]);
      });

      test('watchBytes', () async {
        final list = <List<int>?>[];
        final watch = db.kv.watchBytes('key');
        watch.listen(list.add);
        await db.kv.set('key', [1, 2, 3]);
        await Future.delayed(const Duration(milliseconds: 100));
        await db.kv.set('key', [1, 2, 3, 4]);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, [
          [1, 2, 3],
          [1, 2, 3, 4]
        ]);
      });

      test('getBytes missing', () async {
        expect(await db.kv.getBytes('key'), null);
      });
      test('getBytes wrong type', () async {
        await db.kv.set('key', 'value');
        expect(
          () async => await db.kv.getBytes('key'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('string list', () {
      test('setStringList', () async {
        await db.kv.setStringList('key', ['value']);
        expect(await db.kv.getStringList('key'), ['value']);
      });
      test('getStringList', () async {
        await db.kv.set('key', ['value']);
        expect(await db.kv.getStringList('key'), ['value']);
      });

      test('watchStringList', () async {
        final list = <List<String>?>[];
        final watch = db.kv.watchStringList('key');
        watch.listen(list.add);
        await db.kv.set('key', ['value']);
        await Future.delayed(const Duration(milliseconds: 100));
        await db.kv.set('key', ['value2']);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, [
          ['value'],
          ['value2']
        ]);
      });

      test('getStringList missing', () async {
        expect(await db.kv.getStringList('key'), null);
      });
      test('getStringList wrong type', () async {
        await db.kv.set('key', 'value');
        expect(
          () async => await db.kv.getStringList('key'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('watch', () {
      test('single', () async {
        final list = <Object?>[];
        final watch = db.kv.watch('key');
        watch.listen(list.add);
        await db.kv.set('key', 'value');
        await Future.delayed(const Duration(milliseconds: 100));
        await db.kv.set('key', 'value2');
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, ['value', 'value2']);
      });

      test('multiple', () async {
        final list = <Object?>[];
        final watch = db.kv.watchAll(keys: ['key', 'key2']);
        watch.listen(list.add);
        await db.kv.set('key', 'value');
        await Future.delayed(const Duration(milliseconds: 100));
        await db.kv.set('key2', 'value2');
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, [
          {'key': 'value'},
          {'key': 'value', 'key2': 'value2'}
        ]);
      });

      test('all', () async {
        final list = <Object?>[];
        final watch = db.kv.watchAll();
        watch.listen(list.add);
        await db.kv.set('key', 'value');
        await Future.delayed(const Duration(milliseconds: 100));
        await db.kv.set('key2', 'value2');
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, [
          {'key': 'value'},
          {'key': 'value', 'key2': 'value2'}
        ]);
      });
    });

    test('setAll', () async {
      await db.kv.setAll({'key': 'value', 'key2': 42});
      expect(await db.kv.getString('key'), 'value');
      expect(await db.kv.getInt('key2'), 42);
    });

    test('search', () async {
      await db.kv.set('key', 'value');
      await db.kv.set('key2', 42);
      expect(await db.kv.search('value'), [
        {'key': 'key', 'value': 'value'}
      ]);
      expect(await db.kv.search('42'), [
        {'key': 'key2', 'value': 42}
      ]);
    });

    test('get all', () async {
      await db.kv.set('key', 'value');
      await db.kv.set('key2', 42);
      expect(await db.kv.getAll(), {'key': 'value', 'key2': 42});
    });

    test('remove all', () async {
      await db.kv.set('key', 'value');
      await db.kv.set('key2', 42);
      await db.kv.removeAll(['key', 'key2']);
      expect(await db.kv.getAll(), {});
    });

    test('clear', () async {
      await db.kv.set('key', 'value');
      await db.kv.clear();
      expect(await db.kv.getString('key'), null);
    });
  });
}

enum TestEnum {
  one,
  two,
  three,
}
