import 'dart:convert';

import 'package:sqlite_async/sqlite_async.dart';

import 'database/database.dart';
import 'database/selectable.dart';

const _tableNodes = '_nodes';
const _tableEdges = '_edges';

const _createSql = '''
CREATE TABLE IF NOT EXISTS $_tableNodes (
    body TEXT NOT NULL,
    id   TEXT GENERATED ALWAYS AS (json_extract(body, '\$.id')) VIRTUAL NOT NULL UNIQUE
);
---
CREATE TABLE IF NOT EXISTS $_tableEdges (
    source     TEXT NOT NULL,
    target     TEXT NOT NULL,
    properties TEXT NOT NULL,
    UNIQUE(source, target, properties) ON CONFLICT REPLACE,
    FOREIGN KEY(source) REFERENCES $_tableNodes(id),
    FOREIGN KEY(target) REFERENCES $_tableNodes(id)
);
''';

typedef Node = ({
  String id,
  Map<String, Object?> body,
});

typedef Edge = ({
  String source,
  String target,
  Map<String, Object?> properties,
});

/// @link https://www.youtube.com/watch?v=GekQqFZm7mA
/// @link https://github.com/dpapathanasiou/simple-graph
class GraphDatabase extends Dao {
  GraphDatabase(super.database);

  @override
  Future<void> migrate(int toVersion, SqliteWriteContext tx, bool down) async {
    if (toVersion == 1) {
      if (down) {
        await tx.execute('DROP TABLE $_tableNodes');
        await tx.execute('DROP TABLE $_tableEdges');
        await tx.execute('DROP INDEX id_idx');
        await tx.execute('DROP INDEX source_idx');
        await tx.execute('DROP INDEX target_idx');
      } else {
        final statements = _createSql.split('---');
        for (final stmt in statements) {
          await tx.execute(stmt);
        }
      }
    }
  }

  Selectable<Node> selectNodes([
    String sql = 'SELECT * FROM $_tableNodes',
    List<Object?> args = const [],
  ]) {
    return database.db.select(
      sql,
      args: args,
      mapper: (row) => (
        id: row['id'] as String,
        body: jsonDecode(row['body'] as String) as Map<String, Object?>,
      ),
    );
  }

  Selectable<Edge> selectEdges([
    String sql = 'SELECT * FROM $_tableEdges',
    List<Object?> args = const [],
  ]) {
    return database.db.select(
      sql,
      args: args,
      mapper: (row) => (
        source: row['source'] as String,
        target: row['target'] as String,
        properties:
            jsonDecode(row['properties'] as String) as Map<String, Object?>,
      ),
    );
  }

  Future<void> deleteEdge(String source, String target) async {
    await database.db.execute(
      'DELETE FROM $_tableEdges WHERE source = ? AND target = ?',
      [source, target],
    );
  }

  Future<void> deleteNode(
    String id, {
    bool cascade = true,
  }) async {
    await database.db.execute(
      'DELETE FROM $_tableNodes WHERE id = ?',
      [id],
    );
    if (cascade) {
      await database.db.execute(
        'DELETE FROM $_tableEdges WHERE source = ? OR target = ?',
        [id, id],
      );
    }
  }

  Future<Edge> insertEdge(
    String source,
    String target, [
    Map<String, Object?> properties = const {},
  ]) async {
    await database.db.execute(
      'INSERT INTO $_tableEdges (source, target, properties) VALUES (?, ?, ?)',
      [source, target, jsonEncode(properties)],
    );
    return (source: source, target: target, properties: properties);
  }

  Future<Node> insertNode(Map<String, Object?> data) async {
    assert(
      data['id'] is String && data['id'].toString().isNotEmpty,
      'id must be a non-empty string',
    );
    await database.db.execute(
      'INSERT INTO $_tableNodes (body) VALUES (?)',
      [jsonEncode(data)],
    );
    return (id: data['id'] as String, body: data);
  }

  Selectable<Edge> selectEdgesInbound(String source) {
    return selectEdges('SELECT * FROM $_tableEdges WHERE source = ?', [source]);
  }

  Selectable<Edge> selectEdgesOutbound(String target) {
    return selectEdges('SELECT * FROM $_tableEdges WHERE target = ?', [target]);
  }

  Selectable<Edge> selectSearchEdges(String source, String target) {
    return selectEdges(
      'SELECT * FROM $_tableEdges WHERE source = ? UNION SELECT * FROM $_tableEdges WHERE target = ?',
      [source, target],
    );
  }

  Selectable<Node> selectNodeById(String id) {
    return selectNodes('SELECT * FROM $_tableNodes WHERE id = ?', [id]);
  }

  Selectable<String> selectTraverseInbound(String source) {
    return database.db.select(
      '''
      WITH RECURSIVE traverse(id) AS (
        SELECT :source
        UNION
        SELECT source FROM $_tableEdges JOIN traverse ON target = id
      ) SELECT id FROM traverse;
      ''',
      args: [source],
      mapper: (row) => row['id'] as String,
    );
  }

  Selectable<String> selectTraverseOutbound(String target) {
    return database.db.select(
      '''
      WITH RECURSIVE traverse(id) AS (
        SELECT :source
        UNION
        SELECT target FROM $_tableEdges JOIN traverse ON source = id
      ) SELECT id FROM traverse;
      ''',
      args: [target],
      mapper: (row) => row['id'] as String,
    );
  }

  Selectable<NodeBody> selectTraverseBodiesInbound(String target) {
    return database.db.select(
      '''
      WITH RECURSIVE traverse(x, y, obj) AS (
        SELECT :source, '()', '{}'
        UNION
        SELECT id, '()', body FROM $_tableNodes JOIN traverse ON id = x
        UNION
        SELECT source, '<-', properties FROM $_tableEdges JOIN traverse ON target = x
      ) SELECT x, y, obj FROM traverse;
      ''',
      args: [target],
      mapper: (row) => (
        x: row['x'] as String,
        y: row['y'] as String,
        obj: jsonDecode(row['obj'] as String) as Map<String, Object?>,
      ),
    );
  }

  Selectable<NodeBody> selectTraverseBodiesOutbound(String target) {
    return database.db.select(
      '''
      WITH RECURSIVE traverse(x, y, obj) AS (
        SELECT :source, '()', '{}'
        UNION
        SELECT id, '()', body FROM $_tableNodes JOIN traverse ON id = x
        UNION
        SELECT target, '->', properties FROM $_tableEdges JOIN traverse ON source = x
      ) SELECT x, y, obj FROM traverse;
      ''',
      args: [target],
      mapper: (row) => (
        x: row['x'] as String,
        y: row['y'] as String,
        obj: jsonDecode(row['obj'] as String) as Map<String, Object?>,
      ),
    );
  }

  Selectable<NodeBody> selectTraverseBodies(String target) {
    return database.db.select(
      '''
      WITH RECURSIVE traverse(x, y, obj) AS (
        SELECT :source, '()', '{}'
        UNION
        SELECT id, '()', body FROM $_tableNodes JOIN traverse ON id = x
        UNION
        SELECT source, '<-', properties FROM $_tableEdges JOIN traverse ON target = x
        UNION
        SELECT target, '->', properties FROM $_tableEdges JOIN traverse ON source = x
      ) SELECT x, y, obj FROM traverse;
      ''',
      args: [target],
      mapper: (row) => (
        x: row['x'] as String,
        y: row['y'] as String,
        obj: jsonDecode(row['obj'] as String) as Map<String, Object?>,
      ),
    );
  }

  Selectable<String> selectTraverse(String target) {
    return database.db.select(
      '''
      WITH RECURSIVE traverse(id) AS (
        SELECT :source
        UNION
        SELECT source FROM $_tableEdges JOIN traverse ON target = id
        UNION
        SELECT target FROM $_tableEdges JOIN traverse ON source = id
      ) SELECT id FROM traverse;
      ''',
      args: [target],
      mapper: (row) => row['id'] as String,
    );
  }

  Future<void> updateNode(Map<String, Object?> data) async {
    assert(
      data['id'] is String && data['id'].toString().isNotEmpty,
      'id must be a non-empty string',
    );
    final id = data['id'] as String;
    await database.db.execute(
      'UPDATE $_tableNodes SET body = ? WHERE id = ?',
      [jsonEncode(data), id],
    );
  }

  Future<void> addGraphData(GraphData data) async {
    for (final node in data.nodes) {
      await insertNode({'id': node.id, 'label': node.label});
    }
    for (final edge in data.edges) {
      await insertEdge(edge.from, edge.to);
    }
  }

  Future<GraphData> getGraphData() async {
    final nodes = await selectNodes().get();
    final edges = await selectEdges().get();
    final graphNodes = nodes.map((node) => (
          id: node.id,
          label: node.body['label'] as String,
        ));
    final graphEdges = edges.map((edge) => (
          from: edge.source,
          to: edge.target,
        ));
    return (
      nodes: graphNodes.toList(),
      edges: graphEdges.toList(),
    );
  }
}
typedef NodeBody = ({String x, String y, Map<String, Object?> obj});

typedef GraphNode = ({String id, String label});
typedef GraphEdge = ({String from, String to});
typedef GraphData = ({List<GraphNode> nodes, List<GraphEdge> edges});
