import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:sqlite_storage/sqlite_storage.dart';

late final Database db;

const GraphData EXAMPLE_GRAPH_DATA = (
  nodes: [
    (id: '1', label: 'circle'),
    (id: '2', label: 'ellipse'),
    (id: '3', label: 'database'),
    (id: '4', label: 'box'),
    (id: '5', label: 'diamond'),
    (id: '6', label: 'dot'),
    (id: '7', label: 'square'),
    (id: '8', label: 'triangle'),
    (id: '9', label: "star"),
  ],
  edges: [
    (from: '1', to: '2'),
    (from: '2', to: '3'),
    (from: '2', to: '4'),
    (from: '2', to: '5'),
    (from: '5', to: '6'),
    (from: '5', to: '7'),
    (from: '6', to: '8'),
    (from: '2', to: '8'),
    (from: '1', to: '8'),
    (from: '1', to: '7'),
    (from: '1', to: '6'),
    (from: '1', to: '5'),
    (from: '1', to: '4'),
    (from: '1', to: '3'),
    (from: '1', to: '9'),
    (from: '9', to: '8'),
    (from: '9', to: '5'),
    (from: '9', to: '3'),
  ]
);

final brightness = ValueNotifier(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDir = await getApplicationDocumentsDirectory();
  final dbPath = '${appDir.path}/app.db';
  db = Database(SqliteDatabase(path: dbPath));
  db.logging.printToConsole = kDebugMode;
  await db.open();
  await db.analytics.sendEvent('event', 'app_launched');
  final col = db.documents.collection('test');
  for (var i = 0; i < 10; i++) {
    final data = {'value': i, 'name': 'item $i'};
    await col.doc('$i').set(data);
    await db.logging.log('item_added -> ${jsonEncode(data)}', level: 1);
  }
  brightness.addListener(() {
    db.analytics.sendEvent('theme', brightness.value.toString());
    db.kv.setEnum('theme-brightness', brightness.value);
  });
  brightness.value =
      (await db.kv.getEnum(ThemeMode.values, 'theme-brightness')) ??
          ThemeMode.system;
  // await db.graph.addGraphData(EXAMPLE_GRAPH_DATA);
  runApp(const Example());
}

class Example extends StatelessWidget {
  const Example({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: brightness,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          themeMode: brightness.value,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: const Home(),
        );
      },
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          DropdownButton<ThemeMode>(
            value: brightness.value,
            items: const [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text('System'),
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text('Light'),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Text('Dark'),
              ),
            ],
            onChanged: (value) {
              brightness.value = value!;
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Counter'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const Counter();
                  },
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Documents'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return Docs(
                      collection: db.documents.collection('test'),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterExampleState();
}

class _CounterExampleState extends State<Counter> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    db.analytics.sendScreenView('home');
    db.kv.watchInt('counter').listen((value) {
      if (mounted) {
        setState(() {
          _counter = value ?? 0;
        });
      }
    });
  }

  void _incrementCounter() {
    db.kv.setInt('counter', _counter + 1);
    db.analytics.sendEvent('counter', 'increment');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Docs extends StatefulWidget {
  const Docs({super.key, required this.collection});

  final Collection collection;

  @override
  State<Docs> createState() => _DocsState();
}

class _DocsState extends State<Docs> {
  late final docs = widget.collection.select().watch();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: docs,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return const Text('Loading...');
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data![index];
              return ListTile(
                title: Text(doc.path),
                subtitle: Text(doc.data.toString()),
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final val = await doc
                      .jsonExtract(['value', 'name']).getSingleOrNull();
                  messenger.hideCurrentSnackBar();
                  messenger.showSnackBar(
                    SnackBar(content: Text('Value: $val')),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
