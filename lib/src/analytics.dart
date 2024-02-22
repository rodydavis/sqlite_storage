import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';

import 'database/database.dart';
import 'database/selectable.dart';

const _table = '_analytics';

const _createSql = '''
CREATE TABLE $_table (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT NOT NULL,
  parameters TEXT NOT NULL,
  date TEXT NOT NULL
);
''';

const _insertSql = '''
INSERT INTO $_table (
  type,
  parameters,
  date
) VALUES (
  :type,
  :parameters,
  :date
);
''';

class AnalyticsDatabase extends Dao {
  AnalyticsDatabase(super.database);
  bool printToConsole = true;
  bool enabled = true;

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

  AnalyticsEvent _mapper(Row row) {
    return (
      type: row['type'] as String,
      parameters:
          jsonDecode(row['parameters'] as String) as Map<String, Object?>,
      date: DateTime.parse(row['date'] as String),
    );
  }

  Future<void> _log(
    String type, {
    Map<String, dynamic> parameters = const {},
  }) async {
    if (!enabled) return;
    final args = jsonEncode(parameters);
    if (printToConsole) developer.log('$type - $args', level: 1);
    await database.db.execute(
      _insertSql,
      [
        type,
        args,
        DateTime.now().toIso8601String(),
      ],
    );
  }

  Future<void> sendScreenView(
    String viewName, {
    Map<String, dynamic>? parameters,
  }) async {
    final args = parameters ?? {};
    args['viewName'] = viewName;
    await _log('screenView', parameters: args);
  }

  Future<void> sendEvent(
    String category,
    String action, {
    String? label,
    int? value,
    Map<String, dynamic>? parameters,
  }) async {
    final args = parameters ?? {};
    args['category'] = category;
    args['action'] = action;
    if (label != null) {
      args['label'] = label;
    }
    if (value != null) {
      args['value'] = value;
    }
    await _log('event', parameters: args);
  }

  Future<void> sendSocial(String network, String action, String target) async {
    final args = <String, dynamic>{};
    args['network'] = network;
    args['action'] = action;
    args['target'] = target;
    await _log('social', parameters: args);
  }

  Future<void> sendTiming(
    String variableName,
    int time, {
    String? label,
    String? category,
  }) async {
    final args = <String, dynamic>{};
    args['variableName'] = variableName;
    args['time'] = time;
    if (label != null) {
      args['label'] = label;
    }
    if (category != null) {
      args['category'] = category;
    }
    await _log('timing', parameters: args);
  }

  Future<void> sendException(
    String description, {
    bool? fatal,
  }) async {
    final args = <String, dynamic>{};
    args['description'] = description;
    if (fatal != null) {
      args['fatal'] = fatal;
    }
    await _log('exception', parameters: args);
  }

  AnalyticsTimer startTimer(
    String variableName, {
    String? category,
    String? label,
  }) {
    return AnalyticsTimer(
      this,
      variableName,
      category: category,
      label: label,
    );
  }

  Selectable<AnalyticsEvent> select() {
    return database.db.select(
      'SELECT * FROM $_table',
      mapper: _mapper,
    );
  }
}

typedef AnalyticsEvent = ({
  String type,
  Map<String, Object?> parameters,
  DateTime date
});

class AnalyticsTimer {
  final AnalyticsDatabase analytics;
  final String variableName;
  final String? category;
  final String? label;

  late final int _startMills;
  int? _endMills;

  AnalyticsTimer(
    this.analytics,
    this.variableName, {
    this.category,
    this.label,
  }) : _startMills = DateTime.now().millisecondsSinceEpoch;

  int get currentElapsedMills => _endMills != null
      ? _endMills! - _startMills
      : DateTime.now().millisecondsSinceEpoch - _startMills;

  Future<void> finish() async {
    if (_endMills != null) return;

    _endMills = DateTime.now().millisecondsSinceEpoch;
    await analytics.sendTiming(
      variableName,
      currentElapsedMills,
      category: category,
      label: label,
    );
  }
}
