// ignore: avoid_web_libraries_in_flutter

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/foundation.dart';
import 'package:sqlite3/wasm.dart';

LazyDatabase connect(
  String dbName, {
  bool logStatements = false,
  bool inMemory = false,
  bool debug = false,
  bool delete = false,
  Future<Uint8List?> Function()? preload,
}) {
  return LazyDatabase(() async {
    final sqliteUrl = Uri.parse('/sqlite3.${debug ? 'debug.' : ''}wasm');
    if (inMemory) {
      final sqlite = await WasmSqlite3.loadFromUrl(sqliteUrl);
      return DatabaseConnection(
        WasmDatabase.inMemory(
          sqlite,
          logStatements: logStatements,
        ),
      );
    }
    final result = await WasmDatabase.open(
      databaseName: dbName.replaceAll('.db', ''),
      sqlite3Uri: sqliteUrl,
      driftWorkerUri: Uri.parse('/drift_worker.js'),
      initializeDatabase: preload,
      localSetup: (db) {
        db.execute('PRAGMA journal_mode=WAL');
        db.execute('PRAGMA busy_timeout=100');
      },
    );

    if (result.missingFeatures.isNotEmpty) {
      // Depending how central local persistence is to your app, you may want
      // to show a warning to the user if only unreliable implementations
      // are available.
      if (kDebugMode) {
        print(
          'Using ${result.chosenImplementation} due to missing browser '
          'features: ${result.missingFeatures}',
        );
      }
    }

    return result.resolvedExecutor;
  });
}

Future<Uint8List?> getDatabaseBytes(String dbName) async {
  return null;
}
