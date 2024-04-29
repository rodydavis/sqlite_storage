// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search.dart';

// ignore_for_file: type=lint
mixin _$SearchDaoMixin on DatabaseAccessor<DriftStorage> {
  SearchIndex get searchIndex => attachedDatabase.searchIndex;
  SearchIndexFts get searchIndexFts => attachedDatabase.searchIndexFts;
  KeyValue get keyValue => attachedDatabase.keyValue;
  Documents get documents => attachedDatabase.documents;
  Analytics get analytics => attachedDatabase.analytics;
  Files get files => attachedDatabase.files;
  Nodes get nodes => attachedDatabase.nodes;
  Edges get edges => attachedDatabase.edges;
  Logging get logging => attachedDatabase.logging;
  Requests get requests => attachedDatabase.requests;
  RequestsQueue get requestsQueue => attachedDatabase.requestsQueue;
  RequestsQueueFiles get requestsQueueFiles =>
      attachedDatabase.requestsQueueFiles;
  Selectable<SearchIndexData> _searchValueLike(String query) {
    return customSelect('SELECT * FROM search_index WHERE value LIKE ?1',
        variables: [
          Variable<String>(query)
        ],
        readsFrom: {
          searchIndex,
        }).asyncMap(searchIndex.mapFromRow);
  }

  Selectable<SearchValueFtsResult> _searchValueFts(String query) {
    return customSelect(
        'SELECT r.id, highlight(search_index_fts, 2, \'<b>\', \'</b>\') AS value, r.created, r.updated FROM search_index_fts INNER JOIN search_index AS r ON r.id = search_index_fts."ROWID" WHERE search_index_fts MATCH ?1 ORDER BY rank',
        variables: [
          Variable<String>(query)
        ],
        readsFrom: {
          searchIndex,
          searchIndexFts,
        }).map((QueryRow row) => SearchValueFtsResult(
          id: row.read<int>('id'),
          value: row.read<String>('value'),
          created: row.read<DateTime>('created'),
          updated: row.read<DateTime>('updated'),
        ));
  }

  Future<int> addSearchIndex(String value, String key, int? ttl) {
    return customInsert(
      'INSERT INTO search_index (value, "key", ttl, created, updated) VALUES (?1, ?2, ?3, datetime(\'now\'), datetime(\'now\'))',
      variables: [
        Variable<String>(value),
        Variable<String>(key),
        Variable<int>(ttl)
      ],
      updates: {searchIndex},
    );
  }

  Selectable<SearchIndexData> getSearchIndexById(int id) {
    return customSelect('SELECT * FROM search_index WHERE id = ?1', variables: [
      Variable<int>(id)
    ], readsFrom: {
      searchIndex,
    }).asyncMap(searchIndex.mapFromRow);
  }

  Selectable<SearchIndexData> getSearchIndexByKey(String key) {
    return customSelect('SELECT * FROM search_index WHERE "key" = ?1',
        variables: [
          Variable<String>(key)
        ],
        readsFrom: {
          searchIndex,
        }).asyncMap(searchIndex.mapFromRow);
  }

  Future<int> deleteSearchIndexById(int id) {
    return customUpdate(
      'DELETE FROM search_index WHERE id = ?1',
      variables: [Variable<int>(id)],
      updates: {searchIndex},
      updateKind: UpdateKind.delete,
    );
  }

  Future<int> deleteSearchIndexByKey(String key) {
    return customUpdate(
      'DELETE FROM search_index WHERE "key" = ?1',
      variables: [Variable<String>(key)],
      updates: {searchIndex},
      updateKind: UpdateKind.delete,
    );
  }

  Future<int> updateSearchIndexById(String value, int? ttl, int id) {
    return customUpdate(
      'UPDATE search_index SET value = ?1, ttl = ?2, updated = datetime(\'now\') WHERE id = ?3',
      variables: [
        Variable<String>(value),
        Variable<int>(ttl),
        Variable<int>(id)
      ],
      updates: {searchIndex},
      updateKind: UpdateKind.update,
    );
  }

  Future<int> updateSearchIndexByKey(String value, int? ttl, String key) {
    return customUpdate(
      'UPDATE search_index SET value = ?1, ttl = ?2, updated = datetime(\'now\') WHERE "key" = ?3',
      variables: [
        Variable<String>(value),
        Variable<int>(ttl),
        Variable<String>(key)
      ],
      updates: {searchIndex},
      updateKind: UpdateKind.update,
    );
  }

  Future<int> removeExpired() {
    return customUpdate(
      'DELETE FROM search_index WHERE ttl IS NOT NULL AND ttl + updated < unixepoch()',
      variables: [],
      updates: {searchIndex},
      updateKind: UpdateKind.delete,
    );
  }
}

class SearchValueFtsResult {
  int id;
  String value;
  DateTime created;
  DateTime updated;
  SearchValueFtsResult({
    required this.id,
    required this.value,
    required this.created,
    required this.updated,
  });
}
