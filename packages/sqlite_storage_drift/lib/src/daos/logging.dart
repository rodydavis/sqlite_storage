import 'dart:async';
import 'dart:developer' as developer;

import 'package:drift/drift.dart';

import '../constants.dart';
import '../database.dart';

part 'logging.g.dart';

@DriftAccessor(include: {'../sql/logging.drift'})
class LoggingDao extends DatabaseAccessor<DriftStorage> with _$LoggingDaoMixin {
  LoggingDao(super.db);

  bool printToConsole = kDebugMode;

  Future<void> log(
    String message, {
    DateTime? time,
    int? sequenceNumber,
    int level = 0,
    String name = '',
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    if (printToConsole) {
      developer.log(
        message,
        time: time,
        sequenceNumber: sequenceNumber,
        level: level,
        name: name,
        zone: zone,
        error: error,
        stackTrace: stackTrace,
      );
    }
    await _add(
      message,
      (time ?? DateTime.now()).millisecondsSinceEpoch,
      sequenceNumber,
      level,
      name,
      error?.toString(),
      stackTrace?.toString(),
    );
  }

  Selectable<Log> _select(int level) => _getAll(level);
  Future<List<Log>> getAll({int level = 0}) => _select(level).get();
  Stream<List<Log>> watchAll({int level = 0}) => _select(level).watch();

  Selectable<Log> _searchAll(String q, int level) => _search('%$q%', level);
  Future<List<Log>> getSearch(String q, {int level = 0}) =>
      _searchAll(q, level).get();
  Stream<List<Log>> watchSearch(String q, {int level = 0}) =>
      _searchAll(q, level).watch();

  Selectable<Log> _selectTimeRange(int level, int start, int end) {
    return _getTimeRange(level, start, end);
  }

  Future<List<Log>> getTimeRange(
    DateTime start,
    DateTime end, {
    int level = 0,
  }) {
    return _selectTimeRange(
      level,
      start.millisecondsSinceEpoch,
      end.millisecondsSinceEpoch,
    ).get();
  }

  Stream<List<Log>> watchTimeRange(
    DateTime start,
    DateTime end, {
    int level = 0,
  }) {
    return _selectTimeRange(
      level,
      start.millisecondsSinceEpoch,
      end.millisecondsSinceEpoch,
    ).watch();
  }

  Selectable<Log> _selectTimeBefore(int level, int time) {
    return _getTimeBefore(level, time);
  }

  Future<List<Log>> getTimeBefore(
    DateTime time, {
    int level = 0,
  }) {
    return _selectTimeBefore(
      level,
      time.millisecondsSinceEpoch,
    ).get();
  }

  Stream<List<Log>> watchTimeBefore(
    DateTime time, {
    int level = 0,
  }) {
    return _selectTimeBefore(
      level,
      time.millisecondsSinceEpoch,
    ).watch();
  }

  Selectable<Log> _selectTimeAfter(int level, int time) {
    return _getTimeAfter(level, time);
  }

  Future<List<Log>> getTimeAfter(
    DateTime time, {
    int level = 0,
  }) {
    return _selectTimeAfter(
      level,
      time.millisecondsSinceEpoch,
    ).get();
  }

  Stream<List<Log>> watchTimeAfter(
    DateTime time, {
    int level = 0,
  }) {
    return _selectTimeAfter(
      level,
      time.millisecondsSinceEpoch,
    ).watch();
  }

  Future<void> deleteAll() => _deleteAll();

  Future<void> deleteBefore(DateTime time) {
    return _deleteBefore(time.millisecondsSinceEpoch);
  }

  Future<void> deleteOlderThan([Duration duration = const Duration(days: 30)]) {
    return deleteBefore(DateTime.now().subtract(duration));
  }
}
