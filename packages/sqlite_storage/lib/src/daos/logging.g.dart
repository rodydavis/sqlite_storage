// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logging.dart';

// ignore_for_file: type=lint
mixin _$LoggingDaoMixin on DatabaseAccessor<DriftStorage> {
  Logging get logging => attachedDatabase.logging;
  KeyValue get keyValue => attachedDatabase.keyValue;
  Documents get documents => attachedDatabase.documents;
  Analytics get analytics => attachedDatabase.analytics;
  Files get files => attachedDatabase.files;
  Nodes get nodes => attachedDatabase.nodes;
  Edges get edges => attachedDatabase.edges;
  Requests get requests => attachedDatabase.requests;
  RequestsQueue get requestsQueue => attachedDatabase.requestsQueue;
  RequestsQueueFiles get requestsQueueFiles =>
      attachedDatabase.requestsQueueFiles;
  SearchIndex get searchIndex => attachedDatabase.searchIndex;
  SearchIndexFts get searchIndexFts => attachedDatabase.searchIndexFts;
  Future<int> _add(String? message, int date, int? sequenceNumber, int level,
      String name, String? error, String? stackTrace) {
    return customInsert(
      'INSERT INTO logging (message, date, sequence_number, level, name, error, stack_trace) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)',
      variables: [
        Variable<String>(message),
        Variable<int>(date),
        Variable<int>(sequenceNumber),
        Variable<int>(level),
        Variable<String>(name),
        Variable<String>(error),
        Variable<String>(stackTrace)
      ],
      updates: {logging},
    );
  }

  Selectable<Log> _getAll(int level) {
    return customSelect(
        'SELECT * FROM logging WHERE level >= ?1 ORDER BY date DESC',
        variables: [
          Variable<int>(level)
        ],
        readsFrom: {
          logging,
        }).asyncMap(logging.mapFromRow);
  }

  Selectable<Log> _getTimeRange(int start, int end, int level) {
    return customSelect(
        'SELECT * FROM logging WHERE date >= ?1 AND date <= ?2 AND level >= ?3 ORDER BY date DESC',
        variables: [
          Variable<int>(start),
          Variable<int>(end),
          Variable<int>(level)
        ],
        readsFrom: {
          logging,
        }).asyncMap(logging.mapFromRow);
  }

  Selectable<Log> _getTimeAfter(int date, int level) {
    return customSelect(
        'SELECT * FROM logging WHERE date > ?1 AND level >= ?2 ORDER BY date DESC',
        variables: [
          Variable<int>(date),
          Variable<int>(level)
        ],
        readsFrom: {
          logging,
        }).asyncMap(logging.mapFromRow);
  }

  Selectable<Log> _getTimeBefore(int date, int level) {
    return customSelect(
        'SELECT * FROM logging WHERE date < ?1 AND level >= ?2 ORDER BY date DESC',
        variables: [
          Variable<int>(date),
          Variable<int>(level)
        ],
        readsFrom: {
          logging,
        }).asyncMap(logging.mapFromRow);
  }

  Future<int> _deleteAll() {
    return customUpdate(
      'DELETE FROM logging',
      variables: [],
      updates: {logging},
      updateKind: UpdateKind.delete,
    );
  }

  Future<int> _deleteBefore(int date) {
    return customUpdate(
      'DELETE FROM logging WHERE date < ?1',
      variables: [Variable<int>(date)],
      updates: {logging},
      updateKind: UpdateKind.delete,
    );
  }

  Selectable<Log> _search(String message, int level) {
    return customSelect(
        'SELECT * FROM logging WHERE message LIKE ?1 AND level >= ?2',
        variables: [
          Variable<String>(message),
          Variable<int>(level)
        ],
        readsFrom: {
          logging,
        }).asyncMap(logging.mapFromRow);
  }
}
