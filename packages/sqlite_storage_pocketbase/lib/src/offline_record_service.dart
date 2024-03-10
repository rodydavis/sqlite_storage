import 'dart:async';

import 'package:pocketbase/pocketbase.dart';
import 'package:sqlite_storage/sqlite_storage.dart';

import 'offline_pocket_base.dart';

class OfflineRecordService extends RecordService {
  OfflineRecordService(
    this._client,
    this._collectionIdOrName,
    this.cacheStrategy,
  ) : super(_client, _collectionIdOrName);

  final CacheStrategy cacheStrategy;
  final String _collectionIdOrName;
  final OfflinePocketBase _client;
  StreamSubscription? _subscription;
  void Function()? _disconnect;
  bool _disposed = false;

  late final Collection col = _client.storage.docs
      .collection('pocketbase')
      .doc(_collectionIdOrName)
      .collection('records');

  Stream<List<RecordModel>> getRecords() async* {
    Future<List<RecordModel>> getRemote() async {
      final items = await getFullList();
      if (cacheStrategy != CacheStrategy.onlineOnly) {
        await saveRecords(items);
      }
      return items;
    }

    Future<List<RecordModel>> getLocal() async {
      final records = await col.getAll();
      return records
          .map((e) => e.data ?? {})
          .where((e) => e['_action'] != 'delete')
          .map(RecordModel.fromJson)
          .toList();
    }

    if (cacheStrategy == CacheStrategy.offlineFirst ||
        cacheStrategy == CacheStrategy.offlineOnly) {
      yield await getLocal();
    }

    try {
      yield await getRemote();
    } catch (e, t) {
      await _client.storage.log.log(
        'Error fetching $_collectionIdOrName records from server $cacheStrategy',
        level: 1,
        error: e,
        stackTrace: t,
      );
      if (cacheStrategy == CacheStrategy.onlineOnly) {
        rethrow;
      }
    }

    if (cacheStrategy != CacheStrategy.onlineOnly) {
      yield* col.watchAll().map((items) => items
          .map((e) => e.data ?? {})
          .where((e) => e['_action'] != 'delete')
          .map(RecordModel.fromJson)
          .toList());
    }
  }

  Stream<RecordModel?> getRecord(String id) async* {
    Future<RecordModel> getRemote() async {
      final item = await getOne(id);
      if (cacheStrategy != CacheStrategy.onlineOnly) {
        await saveRecords([item]);
      }
      return item;
    }

    Future<RecordModel?> getLocal() async {
      final record = await col.doc(id).get();
      if (record == null) return null;
      final data = record.data ?? {};
      if (data['_action'] == 'delete') return null;
      return RecordModel.fromJson(data);
    }

    if (cacheStrategy == CacheStrategy.offlineFirst ||
        cacheStrategy == CacheStrategy.offlineOnly) {
      yield await getLocal();
    }

    try {
      yield await getRemote();
    } catch (e, t) {
      await _client.storage.log.log(
        'Error fetching $_collectionIdOrName record $id from server $cacheStrategy',
        level: 1,
        error: e,
        stackTrace: t,
      );
      if (cacheStrategy == CacheStrategy.onlineOnly) {
        rethrow;
      } else {
        yield null;
      }
    }
  }

  Future<void> saveRecords(List<RecordModel> items) async {
    await _client.storage.transaction(() async {
      for (final item in items) {
        final doc = col.doc(item.id);
        await doc.set(item.toJson());
      }
    });
    await _client.storage.log.log(
      'Saved ${items.length} $_collectionIdOrName records from server',
    );
  }

  Future<void> saveRecord(RecordModel model, CrudAction action) async {
    final id = model.id;
    try {
      if (cacheStrategy == CacheStrategy.offlineFirst ||
          cacheStrategy == CacheStrategy.offlineOnly) {
        await col.doc(id).set(model.toJson());
      }
      if (cacheStrategy != CacheStrategy.offlineOnly) {
        switch (action) {
          case CrudAction.create:
            await create(body: model.toData());
            break;
          case CrudAction.update:
            await update(id, body: model.toData());
            break;
          case CrudAction.delete:
            await delete(id);
            break;
          default:
        }
      }
    } catch (e, t) {
      await _client.storage.log.log(
        'Error saving $_collectionIdOrName record $id to server',
        error: e,
        stackTrace: t,
        level: 1,
      );
      if (cacheStrategy == CacheStrategy.onlineOnly) {
        rethrow;
      } else {
        await col.doc(id).set({
          ...model.toJson(),
          '_synced': false,
          '_action': action.name,
        });
      }
    }
  }

  Future<void> retryLocalChanges() async {
    final items = await col.getAll();
    final notSynced = items
        .map((e) => e.data ?? {})
        .where((e) => e['_synced'] == false)
        .map(RecordModel.fromJson)
        .toList();
    for (final item in notSynced) {
      final id = item.id;
      try {
        final action = item.getStringValue('_action');
        if (action == CrudAction.create.name) {
          await create(body: item.toData());
          await col.doc(id).set(item.toJson());
        } else if (action == CrudAction.update.name) {
          await update(id, body: item.toData());
          await col.doc(id).set(item.toJson());
        } else if (action == CrudAction.delete.name) {
          await delete(id);
          await col.doc(id).remove();
        }
      } catch (e, t) {
        await _client.storage.log.log(
          'Error retry saving $_collectionIdOrName record $id to server',
          error: e,
          stackTrace: t,
          level: 1,
        );
      }
    }
  }

  void onRecordEvent(RecordSubscriptionEvent event) async {
    final r = event.record;
    if (r == null) return;
    final doc = col.doc(r.id);
    switch (event.action) {
      case 'create':
      case 'update':
        await doc.set(r.toJson());
        break;
      case 'delete':
        await doc.remove();
        break;
      default:
    }
  }

  Future<void> init() async {
    _subscription ??= connect().listen((_) {});
  }

  Stream<void> connect({
    Duration delay = const Duration(minutes: 5),
  }) async* {
    while (!_disposed && cacheStrategy != CacheStrategy.offlineOnly) {
      try {
        _disconnect ??= await subscribe('*', onRecordEvent);
        await retryLocalChanges();
        final local = await col.getAll();
        if (local.isEmpty) {
          final items = await getFullList();
          await saveRecords(items);
        }
      } catch (e, t) {
        await _client.storage.log.log(
          'Error connect $_collectionIdOrName to server',
          error: e,
          stackTrace: t,
          level: 1,
        );
      }
      await Future.delayed(delay);
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _disconnect?.call();
    _disconnect = null;
    _disposed = true;
  }
}

enum CacheStrategy {
  offlineOnly,
  offlineFirst,
  onlineFirst,
  onlineOnly,
}

enum CrudAction {
  create,
  update,
  delete,
}

extension on RecordModel {
  Map<String, dynamic> toData() {
    final map = toJson();
    map.remove('collectionId');
    map.remove('collectionName');
    map.remove('expand');
    map.remove('created');
    map.remove('updated');
    return map;
  }
}
