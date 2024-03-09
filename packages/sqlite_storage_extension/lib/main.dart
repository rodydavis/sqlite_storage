import 'dart:convert';

import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:signals/signals_flutter.dart';

void main() {
  runApp(const DevToolsExtension(child: SqliteStorageExtension()));
}

final getDatabases = serviceManager
    .callServiceExtensionOnMainIsolate('ext.sqlite_storage.getDatabases')
    .then((res) {
  final databases = (res.json?['databases'] as List).cast<String>();
  return databases;
}).toSignal();
final getDatabase = serviceManager
    .callServiceExtensionOnMainIsolate('ext.sqlite_storage.getDatabase')
    .then((res) {
  final database = res.json?['database'] as String?;
  return database;
}).toSignal();

// final executeSql = serviceManager.callServiceExtensionOnMainIsolate('ext.sqlite_storage.executeSql').toSignal();
// final getSql = serviceManager.callServiceExtensionOnMainIsolate('ext.sqlite_storage.getSql').toSignal();

class SqliteStorageExtension extends StatefulWidget {
  const SqliteStorageExtension({super.key});

  @override
  State<SqliteStorageExtension> createState() => _SqliteStorageExtensionState();
}

class _SqliteStorageExtensionState extends State<SqliteStorageExtension> {
  final ready = serviceManager.onServiceAvailable.toSignal();
  final tables = [
    ('Key/Value', 'key_value'),
    ('Documents', 'documents'),
    ('Files', 'files'),
    ('Logging', 'logging'),
    ('Analytics', 'analytics'),
    ('Request Cache', 'requests'),
    // ('Offline Queue', '_offline_queue'),
    ('Graph', 'graph'),
  ];
  final table = signal('key_value');

  @override
  void initState() {
    super.initState();
    refresh().ignore();
  }

  Future<void> refresh() async {
    await serviceManager.onServiceAvailable;
    await getDatabases.refresh();
    await getDatabase.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sqlite Storage Viewer'),
        centerTitle: false,
        actions: [
          const DatabaseSelector(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refresh,
          ),
        ],
      ),
      body: Watch.builder(
        builder: (context) {
          if (ready.value.value == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final databases = getDatabases.value.value;
          final current = getDatabase.value.value ?? databases?.firstOrNull;
          if (current == null) {
            return const Center(child: Text('No database selected'));
          }
          return Row(
            children: [
              SizedBox(
                width: 200,
                child: ListView(
                  children: [
                    for (final (name, table) in tables)
                      ListTile(
                        title: Text(name),
                        selected: table == this.table.value,
                        onTap: () {
                          this.table.value = table;
                        },
                      ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: SizedBox.expand(
                  child: Watch.builder(builder: (context) {
                    if (table.value == 'graph') {
                      return const GraphViewer();
                    }
                    return TableViewer(
                      key: ValueKey(table.value),
                      table: table.value,
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class TableViewer extends StatefulWidget {
  const TableViewer({super.key, required this.table});

  final String table;

  @override
  State<TableViewer> createState() => _TableViewerState();
}

class _TableViewerState extends State<TableViewer> {
  late final getData = serviceManager.callServiceExtensionOnMainIsolate(
      'ext.sqlite_storage.executeSql',
      args: {
        'sql': 'SELECT * FROM ${widget.table}',
        'args': '[]',
      }).then((res) {
    final columns = (res.json?['columns'] as List).cast<String>();
    final values = (res.json?['rows'] as List).cast<List<Object?>>();
    return (columns, values);
  }).toSignal();

  @override
  void dispose() {
    getData.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Watch.builder(
      builder: (context) {
        final data = getData.value.value;
        if (data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: PaginatedDataTable(
              source: SqlDataProvider(data),
              columns: [
                for (final column in data.$1) DataColumn(label: Text(column)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SqlDataProvider extends DataTableSource {
  final (List<String>, List<List<Object?>>) data;

  SqlDataProvider(this.data);

  @override
  DataRow? getRow(int index) {
    final (_, values) = data;
    final row = values[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        for (final item in row) DataCell(Text(item?.toString() ?? '')),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.$2.length;

  @override
  int get selectedRowCount => 0;
}

class DatabaseSelector extends StatelessWidget {
  const DatabaseSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch.builder(
      builder: (context) {
        final databases = getDatabases.value.value ?? [];
        if (databases.isEmpty) {
          return const SizedBox.shrink();
        }
        if (databases.length == 1) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(databases.first),
          );
        }
        final current = getDatabase.value.value;
        if (!databases.contains(current)) {
          return const SizedBox.shrink();
        }
        return DropdownButton<String>(
          value: current,
          items: [
            for (final database in databases)
              DropdownMenuItem(
                value: database,
                child: Text(database),
              ),
          ],
          onChanged: (value) async {
            final idx = databases.indexOf(value!);
            await serviceManager.callServiceExtensionOnMainIsolate(
              'ext.sqlite_storage.setDatabase',
              args: {'index': idx},
            );
            await getDatabase.refresh();
          },
        );
      },
    );
  }
}

class GraphViewer extends StatefulWidget {
  const GraphViewer({super.key});

  @override
  State<GraphViewer> createState() => _GraphViewerState();
}

class _GraphViewerState extends State<GraphViewer> {
  Graph graph = Graph();
  Algorithm builder = FruchtermanReingoldAlgorithm();
  final getGraphData = serviceManager
      .callServiceExtensionOnMainIsolate('ext.sqlite_storage.getGraphData')
      .then((res) {
    final raw = res.json ?? {};
    final nodes = (raw['nodes'] as List).cast<Map<String, dynamic>>();
    final edges = (raw['edges'] as List).cast<Map<String, dynamic>>();
    return (nodes, edges);
  });

  final nodes = <String, DbNode>{};
  final loaded = signal(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadData());
  }

  @override
  void reassemble() {
    super.reassemble();
    // Needed to reset graph on hot reload
    loadData();
  }

  Future<void> loadData() async {
    loaded.value = false;

    final nodeMap = <String, Node>{};
    this.nodes.clear();
    graph = Graph();
    builder = FruchtermanReingoldAlgorithm();

    // Load graph data
    final data = await getGraphData;
    final nodes = data.$1
        .map((e) => (
              id: e['id'] as String,
              label: e['label'] as String?,
              body: null,
            ))
        .toList();
    final edges = data.$2
        .map((e) => (
              source: e['from'] as String,
              target: e['to'] as String,
            ))
        .toList();

    for (final node in nodes) {
      final newNode = Node.Id(node.id);
      nodeMap[node.id] = newNode;
      this.nodes[node.id] = node;
      graph.addNode(newNode);
    }
    for (final edge in edges) {
      final source = nodeMap[edge.source];
      final target = nodeMap[edge.target];
      if (source != null && target != null) {
        graph.addEdge(source, target);
      }
    }

    loaded.value = true;
  }

  Widget buildNode(BuildContext context, Node node) {
    final dbNode = nodes[node.key!.value];
    final data = jsonDecode(dbNode?.body ?? '{}') as Map<String, dynamic>;
    final label = dbNode?.label ?? data['label'] ?? '';
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded.watch(context)) {
      return const Center(child: CircularProgressIndicator());
    }
    if (nodes.isEmpty) {
      return const Center(child: Text('No Data Loaded'));
    }
    return LayoutBuilder(builder: (context, dimens) {
      return SizedBox.expand(
        child: InteractiveViewer(
          constrained: false,
          boundaryMargin: EdgeInsets.symmetric(
            horizontal: dimens.maxWidth * 0.75,
            vertical: dimens.maxHeight * 0.75,
          ),
          minScale: 0.01,
          maxScale: 5.6,
          child: GraphView(
            key: UniqueKey(),
            graph: graph,
            algorithm: builder,
            paint: Paint()
              ..color = Theme.of(context).colorScheme.primary
              ..strokeWidth = 1
              ..style = PaintingStyle.stroke,
            builder: (node) => buildNode(context, node),
          ),
        ),
      );
    });
  }
}

typedef DbNode = ({
  String id,
  String? body,
  String? label,
});

typedef DbEdge = ({
  String source,
  String target,
});
