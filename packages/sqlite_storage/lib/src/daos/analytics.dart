import 'dart:developer' as developer;

import 'package:drift/drift.dart';

import '../constants.dart';
import '../database.dart';

part 'analytics.g.dart';

@DriftAccessor(include: {'../sql/analytics.drift'})
class AnalyticsDao extends DatabaseAccessor<DriftStorage>
    with _$AnalyticsDaoMixin {
  AnalyticsDao(super.db);

  bool enabled = true;
  bool printToConsole = kDebugMode;

  Future<void> _log(
    String type, {
    Map<String, dynamic> parameters = const {},
  }) async {
    if (!enabled) return;
    if (printToConsole) developer.log('$type - $parameters', level: 1);
    await _add(
      type,
      parameters,
      DateTime.now().millisecondsSinceEpoch,
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

  Future<List<AnalyticsEvent>> getAll() => _getAll().get();
  Stream<List<AnalyticsEvent>> watchAll() => _getAll().watch();
}

class AnalyticsTimer {
  final AnalyticsDao analytics;
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
