# signal_db

Set of helpers for sqlite_async that add convenient APIs for working with common data types.

## Installing

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  signal_db:
    git:
      url: git://github.com/rodydavis/signal_db.git
      ref: main
```

## Usage

```dart
import 'package:signal_db/signal_db.dart';
import 'package:sqlite_async/sqlite_async.dart';

final db = Database(SqliteDatabase(path: 'app.db'));
await db.open();
...
await db.close();
```

## Key/Value

```dart
import 'package:signal_db/signal_db.dart';
import 'package:sqlite_async/sqlite_async.dart';

final Database db = ...;
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

## Documents

```dart
import 'package:signal_db/signal_db.dart';
import 'package:sqlite_async/sqlite_async.dart';

final Database db = ...;
final docs = db.documents;

// Document
final doc = docs.doc('collection', 'id'); // Document
await doc.set({'key': 'value'});
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
```

## Files

```dart
import 'package:signal_db/signal_db.dart';
import 'package:sqlite_async/sqlite_async.dart';

final Database db = ...;
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

## Graph Database

```dart
import 'package:signal_db/signal_db.dart';
import 'package:sqlite_async/sqlite_async.dart';

final Database db = ...;
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

## Requests

```dart
import 'package:signal_db/signal_db.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:http/http.dart' as http;

final Database db = ...;
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