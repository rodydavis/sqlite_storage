import 'package:drift/drift.dart';

import '../converters.dart';
import '../database.dart';

part 'graph.g.dart';

@DriftAccessor(include: {'../sql/graph.drift'})
class GraphDao extends DatabaseAccessor<DriftStorage> with _$GraphDaoMixin {
  GraphDao(super.db);

  Selectable<DatabaseNode> selectNodes() => _getNodes();
  Selectable<DatabaseEdge> selectEdges() => _getEdges();

  Future<GraphData> getGraphData() async {
    final nodes = await selectNodes().get();
    final edges = await selectEdges().get();
    final graphNodes = nodes.map((node) => (
          id: node.id,
          label: node.body['label'] as String? ?? '',
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

  Future<void> addGraphData(GraphData data) async {
    for (final node in data.nodes) {
      await insertNode({'id': node.id, 'label': node.label});
    }
    for (final edge in data.edges) {
      await insertEdge(edge.from, edge.to);
    }
  }

  Future<DatabaseNode> insertNode(Map<String, Object?> data) {
    assert(
      data['id'] is String && data['id'].toString().isNotEmpty,
      'id must be a non-empty string',
    );
    return _insertNode(data).then((value) => value.first);
  }

  Future<void> updateNode(Map<String, Object?> data) {
    assert(
      data['id'] is String && data['id'].toString().isNotEmpty,
      'id must be a non-empty string',
    );
    final id = data['id'] as String;
    return _updateNode(data, id);
  }

  Future<void> deleteEdge(String source, String target) {
    return _deleteEdge(source, target);
  }

  Future<void> deleteNode(
    String id, {
    bool cascade = true,
  }) async {
    await _deleteNode(id);
    if (cascade) {
      await _deleteEdgesForNode(id);
    }
  }

  Future<DatabaseEdge> insertEdge(
    String source,
    String target, [
    Map<String, Object?> properties = const {},
  ]) {
    return _insertEdge(source, target, properties).then((value) => value.first);
  }

  Future<void> deleteEdges() {
    return _deleteAllEdges();
  }

  Future<void> deleteNodes() {
    return _deleteAllNodes();
  }
}

typedef NodeBody = ({String x, String y, Map<String, Object?> obj});
typedef GraphNode = ({String id, String label});
typedef GraphEdge = ({String from, String to});
typedef GraphData = ({List<GraphNode> nodes, List<GraphEdge> edges});
