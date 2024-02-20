import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:sqlite_storage/sqlite_storage.dart';
import 'package:test/test.dart';

import 'utils/db.dart';

void main() {
  final inner = TestHttpClient();
  final tempDir = tempDirFor('requests');
  final tempFile = File('${tempDir.path}/test.db')..createSync(recursive: true);
  late Database db;

  setUp(() async {
    resetDir('requests');
    tempFile.createSync(recursive: true);
    db = Database(SqliteDatabase(
      path: tempFile.path,
      options: const SqliteOptions(journalMode: SqliteJournalMode.wal),
    ));
    db.innerClient = inner;
    inner.count = 0;
    await db.open();
    await Future.delayed(const Duration(milliseconds: 100));
  });

  tearDown(() async {
    await db.close();
  });

  const base = 'http://localhost:8080';
  final uri = Uri.parse(base);

  group('requests', () {
    group('cache', () {
      test('check if response if returned normal from inner', () async {
        final res = await inner.get(uri);
        expect(res.statusCode, 200);
        expect(res.headers['Content-Type'], 'application/json');
      });

      test('check if response if returned normal', () async {
        final res = await db.requests.get(uri).first;
        expect(res.statusCode, 200);
        expect(res.headers['Content-Type'], 'application/json');
      });
    });

    group('check repeated calls', () {
      test('check 3 tries with cache control of max age 10', () async {
        final client = db.requests;
        // Set cache control header
        inner.headers[RequestsDatabase.cacheControlKey] = 'max-age=10';
        var res = await client.get(uri).first;

        expect(res.statusCode, 200);
        expect(res.headers['Content-Type'], 'application/json');
        expect(inner.count, 1);
        expect(res.headers[RequestsDatabase.cacheControlKey], 'max-age=10');

        res = await client.get(uri).first;
        expect(res.statusCode, 200);
        expect(res.headers['Content-Type'], 'application/json');
        expect(inner.count, 1);
        expect(res.headers[RequestsDatabase.cacheControlKey], 'max-age=10');

        res = await client.get(uri).first;
        expect(res.statusCode, 200);
        expect(res.headers['Content-Type'], 'application/json');
        expect(inner.count, 1);
        expect(res.headers[RequestsDatabase.cacheControlKey], 'max-age=10');
      });

      test('check 3 tries with cache control of max age 3 with delay',
          () async {
        final client = db.requests;
        // Set cache control header
        inner.headers[RequestsDatabase.cacheControlKey] = 'max-age=3';
        var res = await client.get(uri).first;

        expect(res.statusCode, 200);
        expect(inner.count, 1);

        res = await client.get(uri).first;
        expect(res.statusCode, 200);
        expect(inner.count, 1);

        await Future.delayed(const Duration(seconds: 4));

        res = await client.get(uri).first;
        expect(res.statusCode, 200);
        expect(inner.count, 2);

        res = await client.get(uri).first;
        expect(res.statusCode, 200);
        expect(inner.count, 2);
      });

      test('check that cache is not saved on error', () async {
        final client = db.requests;
        // Set cache control header
        inner.headers[RequestsDatabase.cacheControlKey] = 'max-age=3';
        inner.error = true;
        var res = await client.get(uri).first;

        expect(res.statusCode, 500);
        expect(inner.count, 0);

        res = await client.get(uri).first;

        expect(res.statusCode, 500);
        expect(inner.count, 0);

        inner.error = false;

        res = await client.get(uri).first;
        expect(res.statusCode, 200);
        expect(inner.count, 1);

        res = await client.get(uri).first;
        expect(res.statusCode, 200);
        expect(inner.count, 1);
      });
    });

    group('Cache-Control header overrides', () {
      test('missing', () async {
        final client = db.requests;
        inner.headers.remove(RequestsDatabase.cacheControlKey);
        var res = await client.get(uri).first;

        expect(res.statusCode, 200);
        expect(inner.count, 1);

        res = await client.get(uri).first;
        expect(res.statusCode, 200);
        expect(inner.count, 2);
      });

      test('max-age', () async {
        final client = db.requests;
        inner.headers.remove(RequestsDatabase.cacheControlKey);
        var res = await client.get(uri, headers: {
          RequestsDatabase.cacheControlKey: 'max-age=10',
        }).first;

        expect(res.statusCode, 200);
        expect(inner.count, 1);

        res = await client.get(uri, headers: {
          RequestsDatabase.cacheControlKey: 'max-age=10',
        }).first;
        expect(res.statusCode, 200);
        expect(inner.count, 1);
      });
    });
  });
}

class TestHttpClient extends BaseClient {
  final headers = <String, String>{};
  int count = 0;
  bool error = false;

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    if (error) {
      return StreamedResponse(
        Stream.value(utf8.encode(jsonEncode({'error': 'test error'}))),
        500,
        headers: {'Content-Type': 'application/json'},
      );
    }
    count++;
    return json({'count': count}, request.headers);
  }

  StreamedResponse json(
      Map<String, dynamic> data, Map<String, String> headers) {
    return StreamedResponse(
      Stream.value(utf8.encode(jsonEncode(data))),
      200,
      headers: {
        ...this.headers,
        ...headers,
        'Content-Type': 'application/json',
      },
    );
  }
}
