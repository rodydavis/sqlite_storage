// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requests.dart';

// ignore_for_file: type=lint
mixin _$RequestsDaoMixin on DatabaseAccessor<DriftStorage> {
  Requests get requests => attachedDatabase.requests;
  KeyValue get keyValue => attachedDatabase.keyValue;
  Documents get documents => attachedDatabase.documents;
  Analytics get analytics => attachedDatabase.analytics;
  Files get files => attachedDatabase.files;
  Nodes get nodes => attachedDatabase.nodes;
  Edges get edges => attachedDatabase.edges;
  Logging get logging => attachedDatabase.logging;
  OfflineRequestQueue get offlineRequestQueue =>
      attachedDatabase.offlineRequestQueue;
  OfflineRequestQueueFiles get offlineRequestQueueFiles =>
      attachedDatabase.offlineRequestQueueFiles;
  Selectable<CachedRequest> _getRequestCacheAll() {
    return customSelect('SELECT * FROM requests', variables: [], readsFrom: {
      requests,
    }).asyncMap(requests.mapFromRow);
  }

  Selectable<CachedRequest> _getRequestCacheById(int id) {
    return customSelect('SELECT * FROM requests WHERE id = ?1', variables: [
      Variable<int>(id)
    ], readsFrom: {
      requests,
    }).asyncMap(requests.mapFromRow);
  }

  Selectable<CachedRequest> _getRequestCacheByUrl(String url) {
    return customSelect('SELECT * FROM requests WHERE url = ?1', variables: [
      Variable<String>(url)
    ], readsFrom: {
      requests,
    }).asyncMap(requests.mapFromRow);
  }

  Future<int> _deleteRequestCacheById(int id) {
    return customUpdate(
      'DELETE FROM requests WHERE id = ?1',
      variables: [Variable<int>(id)],
      updates: {requests},
      updateKind: UpdateKind.delete,
    );
  }

  Future<int> _deleteRequestCacheByUrl(String url) {
    return customUpdate(
      'DELETE FROM requests WHERE url = ?1',
      variables: [Variable<String>(url)],
      updates: {requests},
      updateKind: UpdateKind.delete,
    );
  }

  Future<int> _saveRequest(
      String url, String headers, Uint8List? body, int date) {
    return customInsert(
      'INSERT OR REPLACE INTO requests (url, headers, body, date) VALUES (?1, ?2, ?3, ?4)',
      variables: [
        Variable<String>(url),
        Variable<String>(headers),
        Variable<Uint8List>(body),
        Variable<int>(date)
      ],
      updates: {requests},
    );
  }
}
