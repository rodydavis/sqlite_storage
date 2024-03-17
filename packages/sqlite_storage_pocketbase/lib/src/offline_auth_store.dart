import 'package:pocketbase/pocketbase.dart';
import 'package:sqlite_storage/sqlite_storage.dart';

class OfflineAuthStore extends AsyncAuthStore {
  final DriftStorage storage;
  static const String _key = 'auth';
  static const String _modelKey = 'auth-model';
  static const String _tokenKey = 'auth-token';
  late final col = storage //
      .docs
      .collection('pocketbase')
      .doc('_auth')
      .collection('records');

  OfflineAuthStore(this.storage, String? initial)
      : super(
          save: (val) async {
            await storage.kv.$string.set(_key, val);
          },
          clear: () async {
            await storage.kv.$string.set(_key, null);
          },
          initial: initial,
        );

  static Future<OfflineAuthStore> init(DriftStorage storage) async {
    String? auth = await storage.kv.$string.get(_key) ?? '';
    if (auth.trim().isEmpty) {
      await storage.kv.$string.set(_key, null);
      auth = null;
    }
    return OfflineAuthStore(storage, auth);
  }

  late final Stream<String?> authEvents = storage.kv.$string.watch(_key);

  late final Stream<RecordModel?> modelEvents = storage.kv.$jsonMap
      .watch(_modelKey)
      .map((e) => e != null ? RecordModel.fromJson(e) : null)
      .map((e) => (e?.id.isEmpty ?? false) ? null : e);

  late final Stream<String?> tokenEvents = storage.kv.$string.watch(_tokenKey);

  @override
  void save(String newToken, newModel) {
    super.save(newToken, newModel);
    storage.kv.$string.set(_tokenKey, newToken).ignore();
    if (newModel is RecordModel) {
      final collection = col.doc(newModel.id);
      collection.set(newModel.toJson()).ignore();
      storage.kv.$jsonMap.set(_modelKey, newModel.toJson()).ignore();
    } else if (newModel is AdminModel) {
      final collection = col.doc(newModel.id);
      collection.set(newModel.toJson()).ignore();
      storage.kv.$jsonMap.set(_modelKey, newModel.toJson()).ignore();
    } else {
      storage.kv.$jsonMap.set(_modelKey, null).ignore();
    }
  }

  @override
  void clear() {
    super.clear();
    storage.kv.$string.set(_tokenKey, null).ignore();
    storage.kv.$jsonMap.set(_modelKey, null).ignore();
  }
}
