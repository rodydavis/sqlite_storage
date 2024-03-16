import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:mime/mime.dart';

import '../database.dart';

part 'files.g.dart';

@DriftAccessor(include: {'../sql/files.drift'})
class FilesDao extends DatabaseAccessor<DriftStorage> with _$FilesDaoMixin {
  FilesDao(super.db);

  Future<void> remove(String path) {
    return _delete(path);
  }

  Future<void> removeAll(List<String> paths) {
    return _deleteWhere(paths);
  }

  Selectable<FileData> search(String query) {
    return _search('%$query%');
  }

  Selectable<FileData?> get(String path) {
    return _get(path);
  }

  Selectable<FileData> getAll({
    List<String> paths = const [],
  }) {
    if (paths.isEmpty) {
      return _getAll();
    } else {
      return _getAllFilter(paths);
    }
  }

  Future<void> clear({
    List<String> paths = const [],
  }) {
    if (paths.isEmpty) {
      return _deleteAll();
    } else {
      return _deleteWhere(paths);
    }
  }

  DatabaseDirectory directory(String path) => DatabaseDirectory(this, path);

  DatabaseFile file(String path) => DatabaseFile(this, path);
}

sealed class DatabaseFileEntity {
  final FilesDao db;
  final String path;
  DatabaseFileEntity(this.db, this.path);

  DatabaseDirectory directory(String path) {
    return DatabaseDirectory(db, '${this.path}/$path');
  }

  DatabaseFile file(String path) {
    return DatabaseFile(db, '${this.path}/$path');
  }

  Future<bool> exists();
}

class DatabaseDirectory extends DatabaseFileEntity {
  DatabaseDirectory(super.db, super.path);

  Selectable<Metadata> list({bool recursive = false}) {
    if (recursive) {
      return db._getFilesForDirectoryRecursive('$path/%').map((e) {
        return (
          created: DateTime.fromMillisecondsSinceEpoch(e.created),
          updated: DateTime.fromMillisecondsSinceEpoch(e.updated),
          mimeType: e.mimeType,
          size: e.size,
          hash: e.hash,
        );
      });
    } else {
      return db._getFilesForDirectory('$path/%').map((e) {
        return (
          created: DateTime.fromMillisecondsSinceEpoch(e.created),
          updated: DateTime.fromMillisecondsSinceEpoch(e.updated),
          mimeType: e.mimeType,
          size: e.size,
          hash: e.hash,
        );
      });
    }
  }

  @override
  Future<bool> exists() async {
    final count = await db //
        ._getFilesForDirectoryRecursiveCount('$path%')
        .getSingleOrNull();
    return (count ?? 0) != 0;
  }
}

typedef Metadata = ({
  DateTime created,
  DateTime updated,
  String? mimeType,
  int? size,
  String? hash,
});

class DatabaseFile extends DatabaseFileEntity {
  DatabaseFile(super.db, super.path);

  @override
  Future<bool> exists() async {
    final item = await db //
        ._get(path)
        .getSingleOrNull();
    return item != null;
  }

  Future<void> delete() async {
    await db._delete(path);
  }

  Future<Metadata?> metadata() async {
    final item = await db //
        ._get(path)
        .getSingleOrNull();
    if (item == null) return null;
    return (
      created: DateTime.fromMillisecondsSinceEpoch(item.created),
      updated: DateTime.fromMillisecondsSinceEpoch(item.updated),
      size: item.size,
      mimeType: item.mimeType,
      hash: item.hash,
    );
  }

  Future<void> writeAsBytes(List<int> bytes) async {
    final mimeType = lookupMimeType(path, headerBytes: bytes);
    await db._set(
      path,
      Uint8List.fromList(bytes),
      mimeType,
      sha256.convert(bytes).toString(),
      bytes.length,
      DateTime.now().millisecond,
      DateTime.now().millisecond,
    );
  }

  Future<void> writeAsString(String str) async {
    await writeAsBytes(utf8.encode(str));
  }

  Selectable<Uint8List?> selectAsBytes() {
    return db._get(path).map((e) => e.data);
  }

  Selectable<String?> selectAsString() {
    return selectAsBytes().map((e) => e == null ? null : utf8.decode(e));
  }

  Future<Uint8List?> readAsBytes() {
    return selectAsBytes().getSingleOrNull();
  }

  Future<String?> readAsString() {
    return selectAsString().getSingleOrNull();
  }

  Stream<Uint8List?> watchAsBytes() {
    return selectAsBytes().watchSingleOrNull();
  }

  Stream<String?> watchAsString() {
    return selectAsString().watchSingleOrNull();
  }
}
