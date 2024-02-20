import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite_async/sqlite_async.dart';
import 'package:http/http.dart' as http;
import 'package:cachecontrol/cachecontrol.dart' as cc;

import 'database/database.dart';
import 'database/selectable.dart';

class RequestsDatabase extends Dao {
  RequestsDatabase(super.database, this.inner);
  final http.Client inner;
  static const cacheControlKey = 'Cache-Control';

  @override
  Future<void> migrate(int toVersion, SqliteWriteContext tx, bool down) async {
    if (toVersion == 1) {
      if (down) {
        await tx.execute('DROP TABLE request_cache');
      } else {
        await tx.execute(_createSql);
      }
    }
  }

  Selectable<CachedRequest> select([
    String sql = 'SELECT * FROM request_cache',
    List<Object?> args = const [],
  ]) {
    return database.db.select(
      sql,
      args: args,
      mapper: (row) => (
        id: row['id'] as int,
        url: Uri.parse(row['url'] as String),
        headers: (jsonDecode(row['headers'] as String) as Map<String, Object?>)
            .cast<String, String>(),
        body: row['body'] as List<int>?,
        date: DateTime.fromMillisecondsSinceEpoch(row['date'] as int),
      ),
    );
  }

  Selectable<CachedRequest> getById(int id) {
    return select('SELECT * FROM request_cache WHERE id = ?', [id]);
  }

  Selectable<CachedRequest> getByUrl(Uri url) {
    return select(
        'SELECT * FROM request_cache WHERE url = ?', [url.toString()]);
  }

  Future<void> deleteById(int id) async {
    await database.db.execute('DELETE FROM request_cache WHERE id = ?', [id]);
  }

  Future<void> deleteByUrl(Uri url) async {
    await database.db
        .execute('DELETE FROM request_cache WHERE url = ?', [url.toString()]);
  }

  Future<Uint8List> setResponse(
    Uri uri,
    Map<String, String> headers,
    http.Response res,
  ) async {
    final bytes = res.bodyBytes;
    await database.db.execute(
      'INSERT OR REPLACE INTO request_cache (url, headers, body, date) VALUES (?, ?, ?, ?)',
      [
        uri.toString(),
        jsonEncode(headers),
        bytes,
        DateTime.now().millisecondsSinceEpoch,
      ],
    );
    return bytes;
  }

  Stream<http.Response> get(
    Uri url, {
    Map<String, String> headers = const {},
    Uint8List? body,
  }) async* {
    final current = await getByUrl(url).getSingleOrNull();
    final state = current?.staleState();
    if (current != null) {
      if (state == CacheState.fresh ||
          state == CacheState.staleWhileRevalidate) {
        yield http.Response.bytes(
          current.asBytes(),
          200,
          request: http.Request('GET', url),
          headers: current.headers,
          persistentConnection: true,
        );
        if (state == CacheState.fresh) return;
      }
    }
    if (state == null ||
        state == CacheState.staleWhileRevalidate ||
        state == CacheState.stale) {
      final res = await inner.get(url, headers: headers);
      if (res.statusCode == 200) {
        yield http.Response.bytes(
          await setResponse(url, res.headers, res),
          res.statusCode,
          request: res.request,
          headers: res.headers,
          persistentConnection: res.persistentConnection,
          reasonPhrase: res.reasonPhrase,
          isRedirect: res.isRedirect,
        );
      } else {
        yield res;
      }
    }
  }

  Future<void> removeStale() async {
    final cache = await select().get();
    for (final item in cache) {
      final state = item.staleState();
      if (state == CacheState.stale) {
        await deleteById(item.id);
      }
    }
  }

  @override
  Future<void> open() async {
    await removeStale();
  }

  DatabaseClient toHttpClient() => DatabaseClient(this);
}

typedef CachedRequest = ({
  int id,
  Uri url,
  Map<String, String> headers,
  List<int>? body,
  DateTime date,
});

extension CachedRequestUtils on CachedRequest {
  String asString() {
    return this.body == null ? '' : utf8.decode(this.body!);
  }

  Map<String, Object?> asJson() {
    final str = asString();
    if (str.isEmpty) return {};
    return jsonDecode(str) as Map<String, Object?>;
  }

  Uint8List asBytes() {
    return Uint8List.fromList(this.body ?? []);
  }

  cc.CacheControl get cacheControl {
    for (final key in headers.keys) {
      if (key.toLowerCase() == RequestsDatabase.cacheControlKey.toLowerCase()) {
        final cacheHeader = headers[key];
        return cc.parse(cacheHeader);
      }
    }
    return cc.parse('');
  }

  CacheState staleState() {
    final cache = cacheControl;
    if (cache.mustRevalidate == true) {
      return CacheState.stale;
    }
    if (cache.noStore != true && cache.noCache != true && cache.maxAge != 0) {
      if (cache.immutable == true) {
        return CacheState.fresh;
      }
      final currentDate = DateTime.now();
      if (cache.maxAge != null) {
        if (currentDate.difference(date).inSeconds > cache.maxAge!) {
          if (cache.staleWhileRevalidate != null) {
            if (currentDate.difference(date).inSeconds >
                cache.staleWhileRevalidate!) {
              return CacheState.staleWhileRevalidate;
            }
          }
          return CacheState.stale;
        } else {
          return CacheState.fresh;
        }
      }
    }
    return CacheState.stale;
  }
}

const _createSql = '''
CREATE TABLE request_cache (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    [url] TEXT NOT NULL,
    headers TEXT NOT NULL,
    body BLOB NOT NULL,
    date INTEGER NOT NULL,
    UNIQUE ([url], headers)
);
---
CREATE TABLE offline_queue (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    [url] TEXT NOT NULL,
    [method] TEXT NOT NULL,
    [body] BLOB,
    [headers] TEXT NOT NULL,
    [retry_count] INTEGER NOT NULL DEFAULT 0,
    [description] TEXT,
    [user] TEXT,
    date INTEGER NOT NULL
);
---
CREATE TABLE offline_queue_files (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    offline_queue_id INTEGER NOT NULL,
    [field] TEXT NOT NULL,
    [value] BLOB NOT NULL
);
''';

enum CacheState {
  fresh,
  stale,
  staleWhileRevalidate,
}

class DatabaseClient extends http.BaseClient {
  final RequestsDatabase db;
  DatabaseClient(this.db);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request.method == 'GET') {
      final res = await db
          .get(
            request.url,
            headers: request.headers,
            body: await request.finalize().toBytes(),
          )
          .first; // ignore staleWhileRevalidate second response
      return res.toStreamedResponse();
    }
    return db.inner.send(request);
  }
}

extension on http.Response {
  http.StreamedResponse toStreamedResponse() {
    return http.StreamedResponse(
      Stream.value(bodyBytes),
      statusCode,
      request: request,
      headers: headers,
      persistentConnection: persistentConnection,
      reasonPhrase: reasonPhrase,
      isRedirect: isRedirect,
    );
  }
}
