import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

final tempDir = Directory.systemTemp.createTempSync('test_data');

Directory tempDirFor(String name) {
  if (!tempDir.existsSync()) {
    tempDir.createSync();
  }
  final dir = Directory('${tempDir.path}/$name');
  resetDir(name);
  return dir;
}

void resetDir(String name) {
  final dir = Directory('${tempDir.path}/$name');
  if (dir.existsSync()) {
    for (final file in dir.listSync(recursive: true).whereType<File>()) {
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }
  dir.createSync(recursive: true);
}

QueryExecutor connection() => NativeDatabase.memory();
