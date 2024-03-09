# sqlite_storage_drift

Common storage interfaces for a SQLite database.

Uses [drift](https://pub.dev/packages/drift) for the underlying database.

## Installing

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  sqlite_storage:
    git:
      url: git://github.com/rodydavis/sqlite_storage.git
      ref: main
      path: packages/sqlite_storage_drift
```

## Usage

```dart
import 'package:sqlite_storage_drift/sqlite_storage_drift.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

final db = DriftStorage(NativeDatabase.memory());
await db.open();
...
await db.close();
```

### Key/Value

```dart
import 'package:sqlite_storage_drift/sqlite_storage_drift.dart';
import 'package:drift/drift.dart';

final DriftStorage db = ...;
final kv = db.kv;

await kv.set('key', 'value');
final value = await kv.get('key'); // 'value'
await kv.remove('key');

// String
await kv.setString('key', 'value');
final value = await kv.getString('key'); // String?
final stream = kv.watchString('key'); // Stream<String?>

// int
await kv.setInt('key', 1);
final value = await kv.getInt('key'); // int?
final stream = kv.watchInt('key'); // Stream<int?>

// double
await kv.setDouble('key', 1.0);
final value = await kv.getDouble('key'); // double?
final stream = kv.watchDouble('key'); // Stream<double?>

// num
await kv.setNum('key', 1);
final value = await kv.getNum('key'); // num?
final stream = kv.watchNum('key'); // Stream<num?>

// bool
await kv.setBool('key', true);
final value = await kv.getBool('key'); // bool?
final stream = kv.watchBool('key'); // Stream<bool?>

// List<String>
await kv.setStringList('key', ['value']);
final value = await kv.getStringList('key'); // List<String>?
final stream = kv.watchStringList('key'); // Stream<List<String>?>

// Bytes
await kv.setBytes('key', [1]);
final value = await kv.getBytes('key'); // List<int>?
final stream = kv.watchBytes('key'); // Stream<List<int>?>

// JsonMap
await kv.setJsonMap('key', {'key': 'value'});
final value = await kv.getJsonMap('key'); // Map<String, dynamic>?
final stream = kv.watchJsonMap('key'); // Stream<Map<String, dynamic>?>

// JsonList
await kv.setJsonList('key', ['value']);
final value = await kv.getJsonList('key'); // List<dynamic>?
final stream = kv.watchJsonList('key'); // Stream<List<dynamic>?>

// Json
await kv.setJson('key', {'key': 'value'});
final value = await kv.getJson('key'); // Object?
final stream = kv.watchJson('key'); // Stream<Object?>
```

### Documents

```dart
import 'package:sqlite_storage_drift/sqlite_storage_drift.dart';
import 'package:drift/drift.dart';

final DriftStorage db = ...;
final docs = db.documents;

// Document
final doc = docs.doc('collection', 'id'); // Document
await doc.set({'key': 'value', 'list': [1, 2, 3]});
await doc.update({'key': 'value 2'}); // partial update
final id = doc.id; // 'id'
final value = await doc.get(); // Map<String, dynamic>?
final stream = doc.watch(); // Stream<Map<String, dynamic>?>
await doc.remove();

// Collection
final collection = docs.collection('collection'); // Collection
final doc = collection.doc('id'); // Document with id
final doc = collection.doc(); // Document with new id
final docs = await collection.select().get(); // List<Map<String, dynamic>>
final stream = collection.select().watch(); // Stream<List<Map<String, dynamic>>>

// Chain
final doc = docs.collection('collection').doc('id-1').collection('sub-collection').doc('id-2');
```

### Files

```dart
import 'package:sqlite_storage_drift/sqlite_storage_drift.dart';
import 'package:drift/drift.dart';

final DriftStorage db = ...;
final files = db.files;

// String
final value = await files.readAsString('path'); // String?
await files.writeAsString('path', 'value');
final stream = files.watchString('path'); // Stream<String?>

// Bytes
final value = await files.readAsBytes('path'); // List<int>?
await files.writeAsBytes('path', [1]);
final stream = files.watchBytes('path'); // Stream<List<int>?>

// Metadata
final info = await files.metadata('path'); // (DateTime, DateTime)?
final exists = await files.exists('path'); // bool

// Delete
await files.delete('path');

// Delete all
await files.clear();
```

### Requests

```dart
import 'package:sqlite_storage_drift/sqlite_storage_drift.dart';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;

final DriftStorage db = ...;
final requests = db.requests;

final innerClient = http.Client();
db.innerClient = innerClient;

// GET
final response = await requests.get(Uri.parse('https://example.com')); // Stream<http.Response>
await for (final res in response) {
  print((res.statusCode, res.body));
}

// Repeated requests with Cache-Control header are cached
final response = await requests.get(Uri.parse('https://example.com'), headers: {'Cache-Control': 'max-age=60'}); // Stream<http.Response>
await for (final res in response) {
  print((res.statusCode, res.body));
}
```

### Graph

```dart
import 'package:sqlite_storage_drift/sqlite_storage_drift.dart';
import 'package:drift/drift.dart';

final DriftStorage db = ...;
final graph = db.graph;

// Node (must have id)
final node = graph.insertNode({'id': '1', 'name': 'Node 1'}); // Node
final nodes = await graph.selectNodes().get();
final stream = graph.selectNodes().watch();
await graph.removeNode(node.id);

// Edges
final nodeA = graph.insertNode({'id': 'A', 'name': 'Node A'});
final nodeB = graph.insertNode({'id': 'B', 'name': 'Node B'});
final edge = graph.insertEdge(nodeA.id, nodeB.id, {'name': 'Edge AB'}); // Edge
final edges = await graph.selectEdges().get();
final stream = graph.selectEdges().watch();
await graph.removeEdge(nodeA.id, nodeB.id);

// Edges inbound
final edges = await graph.selectEdgesInbound(node.id).get();

// Edges outbound
final edges = await graph.selectEdgesOutbound(node.id).get();

// Select edges
final edges = await graph.selectSearchEdges(nodeA.id, nodeB.id).get();

// Node by id
final node = await graph.selectNodeById(node.id).get();

// Traverse inbound
final ids = await graph.selectTraverseInbound(node.id).get();

// Traverse outbound
final ids = await graph.selectTraverseOutbound(node.id).get();

// Traverse bodies inbound
final nodes = await graph.selectTraverseBodiesInbound(node.id).get();

// Traverse bodies outbound
final nodes = await graph.selectTraverseBodiesOutbound(node.id).get();

// Traverse bodies
final nodes = await graph.selectTraverseBodies(node.id).get();

// Traverse
final nodes = await graph.selectTraverse(node.id).get();
```

### Logging

```dart
import 'package:sqlite_storage_drift/sqlite_storage_drift.dart';
import 'package:drift/drift.dart';

final DriftStorage db = ...;
final log = db.logging;

await log.log('message', level: 1);
final logs = await log.select().get();
```

### Analytics

```dart
import 'package:sqlite_storage_drift/sqlite_storage_drift.dart';
import 'package:drift/drift.dart';

final DriftStorage db = ...;
final analytics = db.analytics;

await analytics.sendEvent('event', 'test');
final events = await analytics.select().get();
```

## Contributing

### Testing

```sh
dart test
```
