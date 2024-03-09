import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:sqlite_storage/sqlite_storage.dart';

import 'connection/connection.dart';
import 'screens/home.dart';

late final DriftStorage db;

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
  db = DriftStorage(connect('app.sqlite'));
  await db.track.sendEvent('event', 'app_launched');
  final col = db.docs.collection('test');
  for (var i = 0; i < 10; i++) {
    final data = {'value': i, 'name': 'item $i'};
    await col.doc('$i').set(data);
    await db.log.log('item_added -> ${jsonEncode(data)}', level: 1);
  }
  brightness.addListener(() {
    db.track.sendEvent('theme', brightness.value.toString());
    db.kv.$enum(ThemeMode.values).set('theme-brightness', brightness.value);
  });
  brightness.value =
      (await db.kv.$enum(ThemeMode.values).get('theme-brightness')) ??
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
