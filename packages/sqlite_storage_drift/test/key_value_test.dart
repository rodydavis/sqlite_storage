import 'dart:io';

import 'package:sqlite_storage_drift/src/database.dart';
import 'package:test/test.dart';

import 'utils/db.dart';

void main() {
  final tempDir = tempDirFor('kv');
  final tempFile = File('${tempDir.path}/test.db')..createSync(recursive: true);
  late DriftStorage db;

  setUp(() async {
    resetDir('kv');
    tempFile.createSync(recursive: true);
    db = DriftStorage(connection());
  });

  tearDown(() async {
    await db.close();
  });

  group('key_value', () {
    group('string', () {
      test('setString', () async {
        await db.kv.$string.set('key', 'value');
        expect(await db.kv.$string.select('key').getSingleOrNull(), 'value');
      });

      test('getString', () async {
        await db.kv.$string.set('key', 'value');
        expect(await db.kv.$string.select('key').getSingleOrNull(), 'value');
      });

      test('watchString', () async {
        final list = <String?>[];
        final watch = db.kv.$string.select('key').watchSingleOrNull();
        watch.listen(list.add);
        await db.kv.$string.set('key', 'value');
        await Future.delayed(const Duration(milliseconds: 100));
        await db.kv.$string.set('key', 'value2');
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, [null, 'value', 'value2']);
      });

      test('getString missing', () async {
        expect(await db.kv.$string.select('key').getSingleOrNull(), null);
      });

      test('getString wrong type', () async {
        await db.kv.set('key', 42);
        expect(
          () async => await db.kv.$string.select('key').getSingleOrNull(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('int', () {
      test('setInt', () async {
        await db.kv.$int.set('key', 42);
        expect(await db.kv.$int.select('key').getSingleOrNull(), 42);
      });
      test('getInt', () async {
        await db.kv.set('key', 42);
        expect(await db.kv.$int.select('key').getSingleOrNull(), 42);
      });

      test('watchInt', () async {
        final list = <int?>[];
        final watch = db.kv.$int.select('key').watchSingleOrNull();
        watch.listen(list.add);
        await db.kv.set('key', 42);
        await Future.delayed(const Duration(milliseconds: 100));
        await db.kv.set('key', 43);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, [null, 42, 43]);
      });

      test('getInt missing', () async {
        expect(await db.kv.$int.select('key').getSingleOrNull(), null);
      });
      test('getInt wrong type', () async {
        await db.kv.set('key', 'value');
        expect(
          () async => await db.kv.$int.select('key').getSingleOrNull(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('double', () {
      test('setDouble', () async {
        await db.kv.$double.set('key', 42);
        expect(await db.kv.$double.select('key').getSingleOrNull(), 42);
      });
      test('getDouble', () async {
        await db.kv.set('key', 42);
        expect(await db.kv.$double.select('key').getSingleOrNull(), 42);
      });

      test('watchDouble', () async {
        final list = <double?>[];
        final watch = db.kv.$double.select('key').watchSingleOrNull();
        watch.listen(list.add);
        await db.kv.set('key', 42);
        await Future.delayed(const Duration(milliseconds: 100));
        await db.kv.set('key', 43);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, [null, 42, 43]);
      });

      test('getDouble missing', () async {
        expect(await db.kv.$double.select('key').getSingleOrNull(), null);
      });
      test('getDouble wrong type', () async {
        await db.kv.set('key', 'value');
        expect(
          () async => await db.kv.$double.select('key').getSingleOrNull(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('num', () {
      test('setNum', () async {
        await db.kv.$num.set('key', 42);
        expect(await db.kv.$num.select('key').getSingleOrNull(), 42);
      });
      test('getNum', () async {
        await db.kv.set('key', 42);
        expect(await db.kv.$num.select('key').getSingleOrNull(), 42);
      });

      test('watchNum', () async {
        final list = <num?>[];
        final watch = db.kv.$num.select('key').watchSingleOrNull();
        watch.listen(list.add);
        await db.kv.set('key', 42);
        await Future.delayed(const Duration(milliseconds: 100));
        await db.kv.set('key', 43);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, [null, 42, 43]);
      });

      test('getNum missing', () async {
        expect(await db.kv.$num.select('key').getSingleOrNull(), null);
      });
      test('getNum wrong type', () async {
        await db.kv.set('key', 'value');
        expect(
          () async => await db.kv.$num.select('key').getSingleOrNull(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('bool', () {
      test('setBool', () async {
        await db.kv.$bool.set('key', true);
        expect(await db.kv.$bool.select('key').getSingleOrNull(), true);
      });
      test('getBool', () async {
        await db.kv.set('key', true);
        expect(await db.kv.$bool.select('key').getSingleOrNull(), true);
      });

      test('watchBool', () async {
        final list = <bool?>[];
        final watch = db.kv.$bool.select('key').watchSingleOrNull();
        watch.listen(list.add);
        await db.kv.set('key', true);
        await Future.delayed(const Duration(milliseconds: 100));
        await db.kv.set('key', false);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, [null, true, false]);
      });

      test('getBool missing', () async {
        expect(await db.kv.$bool.select('key').getSingleOrNull(), null);
      });
      test('getBool wrong type', () async {
        await db.kv.set('key', 'value');
        expect(
          () async => await db.kv.$bool.select('key').getSingleOrNull(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('enum', () {
      test('setEnum', () async {
        await db.kv.$enum(TestEnum.values).set('key', TestEnum.one);
        expect(
            await db.kv.$enum(TestEnum.values).select('key').getSingleOrNull(),
            TestEnum.one);
      });
      test('getEnum', () async {
        await db.kv.$enum(TestEnum.values).set('key', TestEnum.one);
        expect(
            await db.kv.$enum(TestEnum.values).select('key').getSingleOrNull(),
            TestEnum.one);
      });

      test('watchEnum', () async {
        final list = <TestEnum?>[];
        final watch =
            db.kv.$enum(TestEnum.values).select('key').watchSingleOrNull();
        watch.listen(list.add);
        await db.kv.$enum(TestEnum.values).set('key', TestEnum.one);
        await Future.delayed(const Duration(milliseconds: 100));
        await db.kv.$enum(TestEnum.values).set('key', TestEnum.two);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, [null, TestEnum.one, TestEnum.two]);
      });

      test('getEnum missing', () async {
        expect(
            await db.kv.$enum(TestEnum.values).select('key').getSingleOrNull(),
            null);
      });
      test('getEnum wrong type', () async {
        await db.kv.set('key', 'value');
        expect(
          () async => await db.kv
              .$enum(TestEnum.values)
              .select('key')
              .getSingleOrNull(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('date time', () {
      test('setDateTime', () async {
        final date = DateTime.now();
        await db.kv.$dateTime.set('key', date);
        expect(
            await db.kv.$dateTime
                .select('key')
                .map((e) => e?.millisecondsSinceEpoch)
                .getSingleOrNull(),
            date.millisecondsSinceEpoch);
      });
      test('getDateTime', () async {
        final date = DateTime.now();
        await db.kv.$dateTime.set('key', date);
        expect(
            await db.kv.$dateTime
                .select('key')
                .map((e) => e?.millisecondsSinceEpoch)
                .getSingleOrNull(),
            date.millisecondsSinceEpoch);
      });

      test('watchDateTime', () async {
        final list = <DateTime?>[];
        final watch = db.kv.$dateTime.select('key').watchSingleOrNull();
        watch.listen(list.add);
        final date = DateTime.now();
        await db.kv.$dateTime.set('key', date);
        await Future.delayed(const Duration(milliseconds: 100));
        final date2 = DateTime.now();
        await db.kv.$dateTime.set('key', date2);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list.map((e) => e?.millisecondsSinceEpoch).toList(),
            [null, date.millisecondsSinceEpoch, date2.millisecondsSinceEpoch]);
      });

      test('getDateTime missing', () async {
        expect(await db.kv.$dateTime.select('key').getSingleOrNull(), null);
      });
      test('getDateTime wrong type', () async {
        await db.kv.set('key', 'value');
        expect(
          () async => await db.kv.$dateTime.select('key').getSingleOrNull(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('duration', () {
      test('setDuration', () async {
        const duration = Duration(seconds: 42);
        await db.kv.$duration.set('key', duration);
        expect(await db.kv.$duration.select("key").getSingleOrNull(), duration);
      });

      test('getDuration', () async {
        const duration = Duration(seconds: 42);
        await db.kv.$duration.set('key', duration);
        expect(await db.kv.$duration.select("key").getSingleOrNull(), duration);
      });

      test('watchDuration', () async {
        final list = <Duration?>[];
        final watch = db.kv.$duration.select('key').watchSingleOrNull();
        watch.listen(list.add);
        const duration = Duration(seconds: 42);
        await db.kv.$duration.set('key', duration);
        await Future.delayed(const Duration(milliseconds: 100));
        const duration2 = Duration(seconds: 43);
        await db.kv.$duration.set('key', duration2);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, [null, duration, duration2]);
      });

      test('getDuration missing', () async {
        expect(await db.kv.$duration.select("key").getSingleOrNull(), null);
      });

      test('getDuration wrong type', () async {
        await db.kv.set('key', 'value');
        expect(
          () async => await db.kv.$duration.select("key").getSingleOrNull(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('json map', () {
      test('setJsonMap', () async {
        await db.kv.$jsonMap.set('key', {'key': 'value'});
        expect(await db.kv.$jsonMap.select('key').getSingleOrNull(),
            {'key': 'value'});
      });
      test('getJsonMap', () async {
        await db.kv.$jsonMap.set('key', {'key': 'value'});
        expect(await db.kv.$jsonMap.select('key').getSingleOrNull(),
            {'key': 'value'});
      });

      test('watchJsonMap', () async {
        final list = <Map<String, Object?>?>[];
        final watch = db.kv.$jsonMap.select('key').watchSingleOrNull();
        watch.listen(list.add);
        await db.kv.$jsonMap.set('key', {'key': 'value'});
        await Future.delayed(const Duration(milliseconds: 100));
        await db.kv.$jsonMap.set('key', {'key': 'value2'});
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, [
          null,
          {'key': 'value'},
          {'key': 'value2'}
        ]);
      });

      test('getJsonMap missing', () async {
        expect(await db.kv.$jsonMap.select('key').getSingleOrNull(), null);
      });
      test('getJsonMap wrong type', () async {
        await db.kv.set('key', 'value');
        expect(
          () async => await db.kv.$jsonMap.select('key').getSingleOrNull(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('json list', () {
      test('setJsonList', () async {
        await db.kv.$jsonList.set('key', ['value']);
        expect(
            await db.kv.$jsonList.select('key').getSingleOrNull(), ['value']);
      });
      test('getJsonList', () async {
        await db.kv.$jsonList.set('key', ['value']);
        await db.kv.$jsonList.set('key2', [
          {'key': 'value'}
        ]);
        expect(
            await db.kv.$jsonList.select('key').getSingleOrNull(), ['value']);
        expect(await db.kv.$jsonList.select('key2').getSingleOrNull(), [
          {'key': 'value'}
        ]);
      });

      test('watchJsonList', () async {
        final list = <List<Object?>?>[];
        final watch = db.kv.$jsonList.select('key').watchSingleOrNull();
        watch.listen(list.add);
        await db.kv.$jsonList.set('key', ['value']);
        await Future.delayed(const Duration(milliseconds: 100));
        await db.kv.$jsonList.set('key', ['value2']);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, [
          null,
          ['value'],
          ['value2']
        ]);
      });

      test('getJsonList missing', () async {
        expect(await db.kv.$jsonList.select('key').getSingleOrNull(), null);
      });
      test('getJsonList wrong type', () async {
        await db.kv.set('key', 'value');
        expect(
          () async => await db.kv.$jsonList.select('key').getSingleOrNull(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('json', () {
      test('setJson', () async {
        await db.kv.$json.set('key', {'key': 'value'});
        expect(await db.kv.$json.select('key').getSingleOrNull(),
            {'key': 'value'});
      });
      test('getJson', () async {
        await db.kv.$json.set('key', {'key': 'value'});
        expect(await db.kv.$json.select('key').getSingleOrNull(),
            {'key': 'value'});
      });

      test('watchJson', () async {
        final list = <Object?>[];
        final watch = db.kv.$json.select('key').watchSingleOrNull();
        watch.listen(list.add);
        await db.kv.$json.set('key', {'key': 'value'});
        await Future.delayed(const Duration(milliseconds: 100));
        await db.kv.$json.set('key', {'key': 'value2'});
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, [
          null,
          {'key': 'value'},
          {'key': 'value2'}
        ]);
      });

      test('getJson missing', () async {
        expect(await db.kv.$json.select('key').getSingleOrNull(), null);
      });
      test('getJson wrong type', () async {
        await db.kv.set('key', 'value');
        expect(
          () async => await db.kv.$json.select('key').getSingleOrNull(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('bytes', () {
      test('setBytes', () async {
        await db.kv.$bytes.set('key', [1, 2, 3]);
        expect(await db.kv.$bytes.get('key'), [1, 2, 3]);
      });
      test('getBytes', () async {
        await db.kv.$bytes.set('key', [1, 2, 3]);
        expect(await db.kv.$bytes.get('key'), [1, 2, 3]);
      });

      test('watchBytes', () async {
        final list = <List<int>?>[];
        final watch = db.kv.$bytes.watch('key');
        watch.listen(list.add);
        await db.kv.$bytes.set('key', [1, 2, 3]);
        await Future.delayed(const Duration(milliseconds: 100));
        await db.kv.$bytes.set('key', [1, 2, 3, 4]);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, [
          null,
          [1, 2, 3],
          [1, 2, 3, 4]
        ]);
      });

      test('getBytes missing', () async {
        expect(await db.kv.$bytes.get('key'), null);
      });
      test('getBytes wrong type', () async {
        await db.kv.set('key', 'value');
        expect(
          () async => await db.kv.$bytes.get('key'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('string list', () {
      test('setStringList', () async {
        await db.kv.$stringList.set('key', ['value']);
        expect(await db.kv.$stringList.get('key'), ['value']);
      });
      test('getStringList', () async {
        await db.kv.$stringList.set('key', ['value']);
        expect(await db.kv.$stringList.get('key'), ['value']);
      });

      test('watchStringList', () async {
        final list = <List<String>?>[];
        final watch = db.kv.$stringList.watch('key');
        watch.listen(list.add);
        await db.kv.$stringList.set('key', ['value']);
        await Future.delayed(const Duration(milliseconds: 100));
        await db.kv.$stringList.set('key', ['value2']);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(list, [
          null,
          ['value'],
          ['value2']
        ]);
      });

      test('getStringList missing', () async {
        expect(await db.kv.$stringList.get('key'), null);
      });
      test('getStringList wrong type', () async {
        await db.kv.set('key', 'value');
        expect(
          () async => await db.kv.$stringList.get('key'),
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
        expect(list, [null, 'value', 'value2']);
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
          {},
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
          {},
          {'key': 'value'},
          {'key': 'value', 'key2': 'value2'}
        ]);
      });
    });

    test('setAll', () async {
      await db.kv.setAll({'key': 'value', 'key2': 42});
      expect(await db.kv.get('key'), 'value');
      expect(await db.kv.get('key2'), 42);
    });

    test('search', () async {
      await db.kv.set('key', 'value');
      await db.kv.set('key2', 42);
      expect(
          await db.kv
              .search('value')
              .get()
              .then((r) => r.map((e) => {e.key: e.value}).toList()),
          [
            {'key': 'value'}
          ]);
      expect(
          await db.kv
              .search('42')
              .get()
              .then((r) => r.map((e) => {e.key: e.value}).toList()),
          [
            {'key2': 42}
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
      expect(await db.kv.get('key'), null);
    });
  });
}

enum TestEnum {
  one,
  two,
  three,
}

extension on DateTime {
  String get short {
    final str = toIso8601String();
    return str.substring(0, 19);
  }
}
