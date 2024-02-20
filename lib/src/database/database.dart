// ignore_for_file: public_member_api_docs, sort_constructors_first
library sqlite_storage;

import 'dart:async';

import 'package:sqlite_async/sqlite_async.dart';
import 'package:http/http.dart' as http;

import '../files.dart';
import '../graph.dart';
import '../key_value.dart';
import '../documents.dart';
import '../requests.dart';

class Database {
  Database(this.db);
  final SqliteDatabase db;
  http.Client innerClient = http.Client();

  late final kv = KeyValueDatabase(this);
  late final documents = DocumentDatabase(this);
  late final files = FilesDatabase(this);
  late final graph = GraphDatabase(this);
  late final requests = RequestsDatabase(this, innerClient);

  List<Dao> get daos => [
        kv,
        documents,
        files,
        graph,
        requests,
      ];

  Future<void> open() async {
    final migrations = SqliteMigrations();
    migrations.add(SqliteMigration(
      1,
      (tx) async {
        for (final dao in daos) {
          dao.migrate(1, tx, false);
        }
      },
    ));
    await migrations.migrate(db);
  }

  Future<void> close() async {
    await db.close();
  }
}

abstract class Dao {
  final Database database;
  Dao(this.database);

  Future<void> migrate(int toVersion, SqliteWriteContext tx, bool down);
}
