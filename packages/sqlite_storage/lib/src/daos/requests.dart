import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:cachecontrol/cachecontrol.dart' as cc;

import '../database.dart';

part 'requests.g.dart';

@DriftAccessor(include: {'../sql/requests.drift'})
class RequestsDao extends DatabaseAccessor<DriftStorage>
    with _$RequestsDaoMixin {
  RequestsDao(super.db);

  http.Client inner = http.Client();
  static const cacheControlKey = 'Cache-Control';

  Selectable<CachedRequest> getById(int id) {
    return _getRequestCacheById(id);
  }

  Selectable<CachedRequest> getByUrl(Uri url) {
    return _getRequestCacheByUrl(url.toString());
  }

  Future<void> deleteById(int id) {
    return _deleteRequestCacheById(id);
  }

  Future<void> deleteByUrl(Uri url) {
    return _deleteRequestCacheByUrl(url.toString());
  }

  Future<void> removeStale() async {
    final cache = await _getRequestCacheAll().get();
    for (final item in cache) {
      final state = item.staleState();
      if (state == CacheState.stale) {
        await deleteById(item.id);
      }
    }
  }

  Future<Uint8List> setResponse(
    Uri uri,
    Map<String, String> headers,
    http.Response res,
  ) async {
    final bytes = res.bodyBytes;
    await _saveRequest(
      uri.toString(),
      jsonEncode(headers),
      bytes,
      DateTime.now().millisecondsSinceEpoch,
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
          headers: current.toHeaders(),
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

  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request.method == 'GET') {
      final res = await get(
        request.url,
        headers: request.headers,
        body: await request.finalize().toBytes(),
      ).first; // ignore staleWhileRevalidate second response
      return res.toStreamedResponse();
    }
    return inner.send(request);
  }

  DatabaseClient toHttpClient() => DatabaseClient(this);
}

extension CachedRequestUtils on CachedRequest {
  String asString() {
    return body == null ? '' : utf8.decode(body!);
  }

  Map<String, String> toHeaders() {
    return (jsonDecode(headers) as Map<String, Object?>).cast<String, String>();
  }

  Map<String, Object?> asJson() {
    final str = asString();
    if (str.isEmpty) return {};
    return jsonDecode(str) as Map<String, Object?>;
  }

  Uint8List asBytes() {
    return Uint8List.fromList(body ?? []);
  }

  cc.CacheControl get cacheControl {
    final h = toHeaders();
    for (final key in h.keys) {
      if (key.toLowerCase() == RequestsDao.cacheControlKey.toLowerCase()) {
        final cacheHeader = h[key];
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
        final time = DateTime.fromMillisecondsSinceEpoch(date);
        if (currentDate.difference(time).inSeconds > cache.maxAge!) {
          if (cache.staleWhileRevalidate != null) {
            if (currentDate.difference(time).inSeconds >
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

enum CacheState {
  fresh,
  stale,
  staleWhileRevalidate,
}

class DatabaseClient extends http.BaseClient {
  final RequestsDao db;
  DatabaseClient(this.db);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return db.send(request);
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
