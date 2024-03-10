import 'package:http/http.dart';

import 'package:pocketbase/pocketbase.dart';
import 'package:sqlite_storage/sqlite_storage.dart';

import 'client/client.dart';
import 'offline_auth_store.dart';
import 'offline_record_service.dart';

class OfflinePocketBase extends PocketBase {
  final DriftStorage storage;
  final OfflineAuthStore offlineAuthStore;

  OfflinePocketBase(
    super.baseUrl,
    this.storage, {
    required this.offlineAuthStore,
    super.httpClientFactory,
    super.lang,
  }) : super(authStore: offlineAuthStore);

  static Future<OfflinePocketBase> init(
    String baseUrl,
    DriftStorage storage, {
    Client Function()? httpClientFactory,
    String lang = "en-US",
  }) async {
    final authStore = await OfflineAuthStore.init(storage);
    return OfflinePocketBase(
      baseUrl,
      storage,
      httpClientFactory: () {
        final client = createClient();
        storage.http.inner = client;
        // return storage.http.toHttpClient();
        return client;
      },
      lang: lang,
      offlineAuthStore: authStore,
    );
  }

  OfflineRecordService localCollection(
    String collectionIdOrName, {
    CacheStrategy strategy = CacheStrategy.offlineFirst,
  }) {
    return OfflineRecordService(
      this,
      collectionIdOrName,
      strategy,
    );
  }
}
