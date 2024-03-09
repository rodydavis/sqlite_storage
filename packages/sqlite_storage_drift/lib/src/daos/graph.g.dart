// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'graph.dart';

// ignore_for_file: type=lint
mixin _$GraphDaoMixin on DatabaseAccessor<DriftStorage> {
  Nodes get nodes => attachedDatabase.nodes;
  Edges get edges => attachedDatabase.edges;
  KeyValue get keyValue => attachedDatabase.keyValue;
  Documents get documents => attachedDatabase.documents;
  Analytics get analytics => attachedDatabase.analytics;
  Files get files => attachedDatabase.files;
  Logging get logging => attachedDatabase.logging;
  Requests get requests => attachedDatabase.requests;
  OfflineRequestQueue get offlineRequestQueue =>
      attachedDatabase.offlineRequestQueue;
  OfflineRequestQueueFiles get offlineRequestQueueFiles =>
      attachedDatabase.offlineRequestQueueFiles;
  Selectable<DatabaseNode> _getNodes() {
    return customSelect('SELECT * FROM nodes', variables: [], readsFrom: {
      nodes,
    }).asyncMap(nodes.mapFromRow);
  }

  Selectable<DatabaseEdge> _getEdges() {
    return customSelect('SELECT * FROM edges', variables: [], readsFrom: {
      edges,
    }).asyncMap(edges.mapFromRow);
  }

  Future<int> _deleteAllNodes() {
    return customUpdate(
      'DELETE FROM nodes',
      variables: [],
      updates: {nodes},
      updateKind: UpdateKind.delete,
    );
  }

  Future<int> _deleteAllEdges() {
    return customUpdate(
      'DELETE FROM edges',
      variables: [],
      updates: {edges},
      updateKind: UpdateKind.delete,
    );
  }

  Future<int> _deleteEdge(String source, String target) {
    return customUpdate(
      'DELETE FROM edges WHERE source = ?1 AND target = ?2',
      variables: [Variable<String>(source), Variable<String>(target)],
      updates: {edges},
      updateKind: UpdateKind.delete,
    );
  }

  Future<int> _deleteNode(String id) {
    return customUpdate(
      'DELETE FROM nodes WHERE id = ?1',
      variables: [Variable<String>(id)],
      updates: {nodes},
      updateKind: UpdateKind.delete,
    );
  }

  Future<int> _deleteEdgesForNode(String id) {
    return customUpdate(
      'DELETE FROM edges WHERE source = ?1 AND target = ?1',
      variables: [Variable<String>(id)],
      updates: {edges},
      updateKind: UpdateKind.delete,
    );
  }

  Future<List<DatabaseEdge>> _insertEdge(
      String source, String target, Map<String, dynamic> properties) {
    return customWriteReturning(
        'INSERT OR REPLACE INTO edges (source, target, properties) VALUES (?1, ?2, ?3) RETURNING *',
        variables: [
          Variable<String>(source),
          Variable<String>(target),
          Variable<String>(Edges.$converterproperties.toSql(properties))
        ],
        updates: {
          edges
        }).then((rows) => Future.wait(rows.map(edges.mapFromRow)));
  }

  Future<List<DatabaseNode>> _insertNode(Map<String, dynamic> body) {
    return customWriteReturning(
            'INSERT OR REPLACE INTO nodes (body) VALUES (?1) RETURNING *',
            variables: [Variable<String>(Nodes.$converterbody.toSql(body))],
            updates: {nodes})
        .then((rows) => Future.wait(rows.map(nodes.mapFromRow)));
  }

  Future<int> _updateNode(Map<String, dynamic> body, String id) {
    return customUpdate(
      'UPDATE nodes SET body = ?1 WHERE id = ?2',
      variables: [
        Variable<String>(Nodes.$converterbody.toSql(body)),
        Variable<String>(id)
      ],
      updates: {nodes},
      updateKind: UpdateKind.update,
    );
  }

  Selectable<DatabaseNode> getNodeById(String id) {
    return customSelect('SELECT * FROM nodes WHERE id = ?1', variables: [
      Variable<String>(id)
    ], readsFrom: {
      nodes,
    }).asyncMap(nodes.mapFromRow);
  }

  Selectable<DatabaseEdge> selectEdgesInbound(String source) {
    return customSelect('SELECT * FROM edges WHERE source = ?1', variables: [
      Variable<String>(source)
    ], readsFrom: {
      edges,
    }).asyncMap(edges.mapFromRow);
  }

  Selectable<DatabaseEdge> selectEdgesOutbound(String source) {
    return customSelect('SELECT * FROM edges WHERE target = ?1', variables: [
      Variable<String>(source)
    ], readsFrom: {
      edges,
    }).asyncMap(edges.mapFromRow);
  }

  Selectable<DatabaseEdge> searchEdges(String source, String target) {
    return customSelect(
        'SELECT * FROM edges WHERE source = ?1 UNION SELECT * FROM edges WHERE target = ?2',
        variables: [
          Variable<String>(source),
          Variable<String>(target)
        ],
        readsFrom: {
          edges,
        }).asyncMap(edges.mapFromRow);
  }

  Selectable<String> traverseInbound(String source) {
    return customSelect(
        'WITH RECURSIVE traverse (id) AS (SELECT ?1 UNION SELECT source FROM edges JOIN traverse ON target = id) SELECT CAST(id AS TEXT) AS _c0 FROM traverse',
        variables: [
          Variable<String>(source)
        ],
        readsFrom: {
          edges,
        }).map((QueryRow row) => row.read<String>('_c0'));
  }

  Selectable<String> traverseOutbound(String source) {
    return customSelect(
        'WITH RECURSIVE traverse (id) AS (SELECT ?1 UNION SELECT target FROM edges JOIN traverse ON source = id) SELECT CAST(id AS TEXT) AS _c0 FROM traverse',
        variables: [
          Variable<String>(source)
        ],
        readsFrom: {
          edges,
        }).map((QueryRow row) => row.read<String>('_c0'));
  }

  Selectable<TraverseBodiesInboundResult> traverseBodiesInbound(String source) {
    return customSelect(
        'WITH RECURSIVE traverse (x, y, obj) AS (SELECT ?1, \'()\', \'{}\' UNION SELECT id, \'()\', body FROM nodes JOIN traverse ON id = x UNION SELECT source, \'<-\', properties FROM edges JOIN traverse ON target = x) SELECT x, y, obj FROM traverse',
        variables: [
          Variable<String>(source)
        ],
        readsFrom: {
          nodes,
          edges,
        }).map((QueryRow row) => TraverseBodiesInboundResult(
          x: row.read<String>('x'),
          y: row.read<String>('y'),
          obj: const JsonMapConverter().fromSql(row.read<String>('obj')),
        ));
  }

  Selectable<TraverseBodiesOutboundResult> traverseBodiesOutbound(
      String source) {
    return customSelect(
        'WITH RECURSIVE traverse (x, y, obj) AS (SELECT ?1, \'()\', \'{}\' UNION SELECT id, \'()\', body FROM nodes JOIN traverse ON id = x UNION SELECT target, \'->\', properties FROM edges JOIN traverse ON source = x) SELECT x, y, obj FROM traverse',
        variables: [
          Variable<String>(source)
        ],
        readsFrom: {
          nodes,
          edges,
        }).map((QueryRow row) => TraverseBodiesOutboundResult(
          x: row.read<String>('x'),
          y: row.read<String>('y'),
          obj: const JsonMapConverter().fromSql(row.read<String>('obj')),
        ));
  }

  Selectable<TraverseBodiesResult> traverseBodies(String source) {
    return customSelect(
        'WITH RECURSIVE traverse (x, y, obj) AS (SELECT ?1, \'()\', \'{}\' UNION SELECT id, \'()\', body FROM nodes JOIN traverse ON id = x UNION SELECT source, \'<-\', properties FROM edges JOIN traverse ON target = x UNION SELECT target, \'->\', properties FROM edges JOIN traverse ON source = x) SELECT x, y, obj FROM traverse',
        variables: [
          Variable<String>(source)
        ],
        readsFrom: {
          nodes,
          edges,
        }).map((QueryRow row) => TraverseBodiesResult(
          x: row.read<String>('x'),
          y: row.read<String>('y'),
          obj: const JsonMapConverter().fromSql(row.read<String>('obj')),
        ));
  }

  Selectable<String> traverse(String source) {
    return customSelect(
        'WITH RECURSIVE traverse (id) AS (SELECT ?1 UNION SELECT source FROM edges JOIN traverse ON target = id UNION SELECT target FROM edges JOIN traverse ON source = id) SELECT id FROM traverse',
        variables: [
          Variable<String>(source)
        ],
        readsFrom: {
          edges,
        }).map((QueryRow row) => row.read<String>('id'));
  }
}

class TraverseBodiesInboundResult {
  String x;
  String y;
  Map<String, dynamic> obj;
  TraverseBodiesInboundResult({
    required this.x,
    required this.y,
    required this.obj,
  });
}

class TraverseBodiesOutboundResult {
  String x;
  String y;
  Map<String, dynamic> obj;
  TraverseBodiesOutboundResult({
    required this.x,
    required this.y,
    required this.obj,
  });
}

class TraverseBodiesResult {
  String x;
  String y;
  Map<String, dynamic> obj;
  TraverseBodiesResult({
    required this.x,
    required this.y,
    required this.obj,
  });
}
