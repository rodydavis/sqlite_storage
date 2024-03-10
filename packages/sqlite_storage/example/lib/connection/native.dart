import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

LazyDatabase connect(
  String dbName, {
  bool logStatements = false,
  bool inMemory = false,
  bool debug = false,
  bool delete = false,
  Future<Uint8List?> Function()? preload,
}) {
  return LazyDatabase(() async {
    if (inMemory) {
      return DatabaseConnection(NativeDatabase.memory());
    }
    final appDir = await getApplicationDocumentsDirectory();
    final file = File(p.join(appDir.path, dbName));

    if (delete) {
      await file.delete(recursive: true);
    }

    if (!file.existsSync()) {
      await file.create(recursive: true);
    }

    final current = await file.readAsBytes();
    if (current.isEmpty) {
      final bytes = await preload?.call();
      if (bytes != null) {
        await file.writeAsBytes(bytes);
      }
    }

    return NativeDatabase.createInBackground(
      file,
      logStatements: logStatements,
      cachePreparedStatements: true,
      setup: (db) {
        db.execute('PRAGMA journal_mode=WAL');
        db.execute('PRAGMA busy_timeout=100');
      },
    );
  });
}

Future<Uint8List?> getDatabaseBytes(String dbName) async {
  final appDir = await getApplicationDocumentsDirectory();
  final file = File(p.join(appDir.path, dbName));
  if (await file.exists()) {
    return file.readAsBytes();
  }
  return null;
}
