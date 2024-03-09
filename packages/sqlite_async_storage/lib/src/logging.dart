import 'dart:async';
import 'dart:developer' as developer;

import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';

import 'database/database.dart';
import 'database/selectable.dart';

const _table = '_logging';

const _createSql = '''
CREATE TABLE $_table (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  message TEXT,
  time INTEGER NOT NULL,
  sequence_number INTEGER,
  level INTEGER NOT NULL,
  name TEXT NOT NULL,
  error TEXT,
  stack_trace TEXT
);
''';

const _insertSql = '''
INSERT INTO $_table (
  message,
  time,
  sequence_number,
  level,
  name,
  error,
  stack_trace
) VALUES (
  :message,
  :time,
  :sequence_number,
  :level,
  :name,
  :error,
  :stack_trace
);
''';

class LoggingDatabase extends Dao {
  LoggingDatabase(super.database);
  bool printToConsole = true;

  @override
  Future<void> migrate(int toVersion, SqliteWriteContext tx, bool down) async {
    if (toVersion == 1) {
      if (down) {
        await tx.execute('DROP TABLE $_table');
      } else {
        await tx.execute(_createSql);
      }
    }
  }

  LogEvent _mapper(Row row) {
    return (
      message: row['message'] as String,
      time: DateTime.fromMillisecondsSinceEpoch(row['time'] as int),
      sequenceNumber: row['sequence_number'] as int?,
      level: row['level'] as int,
      name: row['name'] as String,
      error: row['error'] as String?,
      stackTrace: row['stack_trace'] as String?,
    );
  }

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
    await database.db.execute(
      _insertSql,
      [
        message,
        (time ?? DateTime.now()).millisecondsSinceEpoch,
        sequenceNumber,
        level,
        name,
        error?.toString(),
        stackTrace?.toString(),
      ],
    );
  }

  Selectable<LogEvent> select([
    String sql = 'SELECT * FROM $_table',
    List<Object?> args = const [],
  ]) {
    return database.db.select(sql, mapper: _mapper, args: args);
  }

  Selectable<LogEvent> query(LogsQuery q) {
    return select(q.query.$1, q.query.$2);
  }
}

typedef LogEvent = ({
  String message,
  DateTime time,
  int? sequenceNumber,
  int level,
  String name,
  String? error,
  String? stackTrace,
});

class LogsQuery {
  final (String, List<Object?>) query;

  bool get containsWhere => query.$1.contains('WHERE');

  const LogsQuery({
    this.query = ('SELECT * FROM $_table', const []),
  });

  LogsQuery timeAfter(DateTime time) {
    return LogsQuery(
      query: (
        '${query.$1} ${containsWhere ? 'AND' : 'WHERE'} time > ?',
        [...query.$2, time.millisecondsSinceEpoch],
      ),
    );
  }

  LogsQuery timeBefore(DateTime time) {
    return LogsQuery(
      query: (
        '${query.$1} ${containsWhere ? 'AND' : 'WHERE'} time < ?',
        [...query.$2, time.millisecondsSinceEpoch],
      ),
    );
  }

  LogsQuery level(int level) {
    return LogsQuery(
      query: (
        '${query.$1} ${containsWhere ? 'AND' : 'WHERE'} level = ?',
        [...query.$2, level],
      ),
    );
  }

  LogsQuery levelGreaterThanOrEqualTo(int level) {
    return LogsQuery(
      query: (
        '${query.$1} ${containsWhere ? 'AND' : 'WHERE'} level >= ?',
        [...query.$2, level],
      ),
    );
  }

  LogsQuery levelGreaterThan(int level) {
    return LogsQuery(
      query: (
        '${query.$1} ${containsWhere ? 'AND' : 'WHERE'} level > ?',
        [...query.$2, level],
      ),
    );
  }

  LogsQuery levelLessThanOrEqualTo(int level) {
    return LogsQuery(
      query: (
        '${query.$1} ${containsWhere ? 'AND' : 'WHERE'} level <= ?',
        [...query.$2, level],
      ),
    );
  }

  LogsQuery levelLessThan(int level) {
    return LogsQuery(
      query: (
        '${query.$1} ${containsWhere ? 'AND' : 'WHERE'} level < ?',
        [...query.$2, level],
      ),
    );
  }
}
