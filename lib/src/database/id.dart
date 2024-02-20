import 'dart:math';

import 'package:shortid/shortid.dart';

final idGenerator = IdGenerator();

/// Short unique id generator
class IdGenerator {
  /// Worker id. This should be unique across concurrent generators intended to
  /// generate unique ids for same target.
  final int workerId;

  /// Reference date used for generation of time part of the id.
  final DateTime refDate;

  int _counter = 0;

  int? _startTimestamp;

  int? _previousTimestamp;

  final Random _rand;

  /// Use [refDate] to configure reference date to compute time part of the id.
  /// Use [workerId] to maintain uniqueness when concurrent generators are used.
  IdGenerator({
    this.workerId = 0,
    DateTime? refDate,
  })  : refDate = refDate ?? DateTime(2019).toUtc(),
        _rand = Random.secure() {
    _startTimestamp =
        (DateTime.now().toUtc().difference(this.refDate)).inMinutes;
  }

  String generate() {
    final sb = StringBuffer();

    final minutes = (DateTime.now().toUtc().difference(refDate)).inMinutes;

    sb.write(_format36(minutes));
    if (_previousTimestamp == minutes) {
      _counter++;
      sb.write(_format36(_counter));
    } else {
      _counter = 0;
    }

    if (workerId != 0) sb.write(_format36(workerId));
    if (minutes != _startTimestamp) {
      sb.write(_format36(_rand.nextInt(256)));
    } else {
      sb.write(_format36(_rand.nextInt(2048) + 256));
    }

    _previousTimestamp = minutes;

    return sb.toString().toUpperCase();
  }

  String generateReadable({String separator = '-'}) {
    final sb = StringBuffer();

    final minutes = (DateTime.now().toUtc().difference(refDate)).inMinutes;

    sb.write(_format26(minutes));
    if (_previousTimestamp == minutes) {
      _counter++;
      sb.write(_format26(_counter));
    } else {
      _counter = 0;
    }

    sb.write(separator);

    if (workerId != 0) sb.write(_format10(workerId));
    if (minutes != _startTimestamp) {
      sb.write(_format10(_rand.nextInt(256)));
    } else {
      sb.write(_format10(_rand.nextInt(2048) + 256));
    }

    _previousTimestamp = minutes;

    return sb.toString().toUpperCase();
  }

  String _format36(int number) => number.toRadixString(36);

  String _format26(int number) {
    final ret = number.toRadixString(26);
    final sb = StringBuffer();

    bool converted = false;

    for (int i = 0; i < ret.length; i++) {
      int c = ret[i].codeUnitAt(0);
      if (c >= 48 && c <= 57) {
        c -= 48;
        converted = true;
        sb.writeCharCode(c + 113);
      } else {
        sb.writeCharCode(c);
      }
    }

    if (!converted) {
      return ret;
    } else {
      return sb.toString();
    }
  }

  String _format16(int number) => number.toRadixString(16);
  String _format10(int number) => number.toRadixString(10);
}

String generateId() {
  return shortid.generate().padLeft(15, "0");
}
