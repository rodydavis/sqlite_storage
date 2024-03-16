import 'dart:convert';

import 'package:http/http.dart';
import 'package:sqlite_storage/sqlite_storage.dart';
import 'package:test/test.dart';

import 'utils/db.dart';

void main() {
  final inner = TestHttpClient();
  late DriftStorage db;

  setUp(() async {
    resetDir('requests');
    db = DriftStorage(connection());
    db.http.inner = inner;
    inner.count = 0;
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
        final res = await db.http.get(uri).first;
        expect(res.statusCode, 200);
        expect(res.headers['Content-Type'], 'application/json');
      });
    });

    group('check repeated calls', () {
      test('check 3 tries with cache control of max age 10', () async {
        final client = db.http;
        // Set cache control header
        inner.headers[RequestsDao.cacheControlKey] = 'max-age=10';
        var res = await client.get(uri).first;

        expect(res.statusCode, 200);
        expect(res.headers['Content-Type'], 'application/json');
        expect(inner.count, 1);
        expect(res.headers[RequestsDao.cacheControlKey], 'max-age=10');

        res = await client.get(uri).first;
        expect(res.statusCode, 200);
        expect(res.headers['Content-Type'], 'application/json');
        expect(inner.count, 1);
        expect(res.headers[RequestsDao.cacheControlKey], 'max-age=10');

        res = await client.get(uri).first;
        expect(res.statusCode, 200);
        expect(res.headers['Content-Type'], 'application/json');
        expect(inner.count, 1);
        expect(res.headers[RequestsDao.cacheControlKey], 'max-age=10');
      });

      test('check 3 tries with cache control of max age 3 with delay',
          () async {
        final client = db.http;
        // Set cache control header
        inner.headers[RequestsDao.cacheControlKey] = 'max-age=3';
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

      test('remove stale', () async {
        final client = db.http;
        // Set cache control header
        inner.headers[RequestsDao.cacheControlKey] = 'max-age=3';
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

        await Future.delayed(const Duration(seconds: 4));
        await client.removeStale();

        res = await client.get(uri).first;
        expect(res.statusCode, 200);
        expect(inner.count, 3);
      });

      test('check that cache is not saved on error', () async {
        final client = db.http;
        // Set cache control header
        inner.headers[RequestsDao.cacheControlKey] = 'max-age=3';
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
        final client = db.http;
        inner.headers.remove(RequestsDao.cacheControlKey);
        var res = await client.get(uri).first;

        expect(res.statusCode, 200);
        expect(inner.count, 1);

        res = await client.get(uri).first;
        expect(res.statusCode, 200);
        expect(inner.count, 2);
      });

      test('max-age', () async {
        final client = db.http;
        inner.headers.remove(RequestsDao.cacheControlKey);
        var res = await client.get(uri, headers: {
          RequestsDao.cacheControlKey: 'max-age=10',
        }).first;

        expect(res.statusCode, 200);
        expect(inner.count, 1);

        res = await client.get(uri, headers: {
          RequestsDao.cacheControlKey: 'max-age=10',
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
