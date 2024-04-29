// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics.dart';

// ignore_for_file: type=lint
mixin _$AnalyticsDaoMixin on DatabaseAccessor<DriftStorage> {
  Analytics get analytics => attachedDatabase.analytics;
  KeyValue get keyValue => attachedDatabase.keyValue;
  Documents get documents => attachedDatabase.documents;
  Files get files => attachedDatabase.files;
  Nodes get nodes => attachedDatabase.nodes;
  Edges get edges => attachedDatabase.edges;
  Logging get logging => attachedDatabase.logging;
  Requests get requests => attachedDatabase.requests;
  RequestsQueue get requestsQueue => attachedDatabase.requestsQueue;
  RequestsQueueFiles get requestsQueueFiles =>
      attachedDatabase.requestsQueueFiles;
  SearchIndex get searchIndex => attachedDatabase.searchIndex;
  SearchIndexFts get searchIndexFts => attachedDatabase.searchIndexFts;
  Future<int> _add(String type, Map<String, dynamic> parameters, int date) {
    return customInsert(
      'INSERT INTO analytics (type, parameters, date) VALUES (?1, ?2, ?3)',
      variables: [
        Variable<String>(type),
        Variable<String>(Analytics.$converterparameters.toSql(parameters)),
        Variable<int>(date)
      ],
      updates: {analytics},
    );
  }

  Selectable<AnalyticsEvent> _getAll() {
    return customSelect('SELECT * FROM analytics ORDER BY date DESC',
        variables: [],
        readsFrom: {
          analytics,
        }).asyncMap(analytics.mapFromRow);
  }
}
