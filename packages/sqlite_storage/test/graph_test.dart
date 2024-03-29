import 'package:sqlite_storage/src/database.dart';
import 'package:test/test.dart';

import 'utils/db.dart';

void main() {
  late DriftStorage db;

  setUp(() async {
    resetDir('graph');
    db = DriftStorage(connection());
  });

  tearDown(() async {
    await db.close();
  });

  group('graph', () {
    test('insert node', () async {
      await db.graph.insertNode({'id': '1', 'name': 'test 1'});

      final nodes = await db.graph.selectNodes().get();

      expect(nodes.map((e) => e.body).toList(), [
        {'id': '1', 'name': 'test 1'}
      ]);
    });

    test('insert edge', () async {
      final a = await db.graph.insertNode({'id': '1', 'name': 'test 1'});
      final b = await db.graph.insertNode({'id': '2', 'name': 'test 2'});
      await db.graph.insertEdge(a.id, b.id);

      final edges = await db.graph.selectEdges().get();

      expect(edges.map((e) => e.source).toList(), ['1']);
      expect(edges.map((e) => e.target).toList(), ['2']);
    });

    test('delete node', () async {
      await db.graph.insertNode({'id': '1', 'name': 'test 1'});
      await db.graph.deleteNode('1');

      final nodes = await db.graph.selectNodes().get();

      expect(nodes, isEmpty);
    });

    test('delete edge', () async {
      final a = await db.graph.insertNode({'id': '1', 'name': 'test 1'});
      final b = await db.graph.insertNode({'id': '2', 'name': 'test 2'});
      await db.graph.insertEdge(a.id, b.id);
      await db.graph.deleteEdge(a.id, b.id);

      final edges = await db.graph.selectEdges().get();

      expect(edges, isEmpty);
    });

    test('edges inbound', () async {
      final a = await db.graph.insertNode({'id': '1', 'name': 'test 1'});
      final b = await db.graph.insertNode({'id': '2', 'name': 'test 2'});
      final c = await db.graph.insertNode({'id': '3', 'name': 'test 3'});
      final d = await db.graph.insertNode({'id': '4', 'name': 'test 4'});
      await db.graph.insertEdge(a.id, b.id);
      await db.graph.insertEdge(a.id, c.id);
      await db.graph.insertEdge(d.id, a.id);

      final edges = await db.graph.selectEdgesInbound(a.id).get();

      expect(edges.map((e) => e.target).toList(), ['2', '3']);
    });

    test('edges outbound', () async {
      final a = await db.graph.insertNode({'id': '1', 'name': 'test 1'});
      final b = await db.graph.insertNode({'id': '2', 'name': 'test 2'});
      final c = await db.graph.insertNode({'id': '3', 'name': 'test 3'});
      final d = await db.graph.insertNode({'id': '4', 'name': 'test 4'});
      await db.graph.insertEdge(a.id, b.id);
      await db.graph.insertEdge(a.id, c.id);
      await db.graph.insertEdge(d.id, a.id);

      final edges = await db.graph.selectEdgesOutbound(a.id).get();

      expect(edges.map((e) => e.source).toList(), ['4']);
    });

    test('search edges', () async {
      final a = await db.graph.insertNode({'id': '1', 'name': 'test 1'});
      final b = await db.graph.insertNode({'id': '2', 'name': 'test 2'});
      final c = await db.graph.insertNode({'id': '3', 'name': 'test 3'});
      final d = await db.graph.insertNode({'id': '4', 'name': 'test 4'});
      await db.graph.insertEdge(a.id, b.id);
      await db.graph.insertEdge(a.id, c.id);
      await db.graph.insertEdge(d.id, a.id);

      final edges = await db.graph.searchEdges(a.id, a.id).get();

      expect(edges.map((e) => e.source).toList(), ['1', '1', '4']);
      expect(edges.map((e) => e.target).toList(), ['2', '3', '1']);
    });

    test('search node by id', () async {
      await db.graph.insertNode({'id': '1', 'name': 'test 1'});

      final node = await db.graph.getNodeById('1').getSingle();

      expect(node.body, {'id': '1', 'name': 'test 1'});
    });

    test('traverse inbound', () async {
      final a = await db.graph.insertNode({'id': '1', 'name': 'test 1'});
      final b = await db.graph.insertNode({'id': '2', 'name': 'test 2'});
      final c = await db.graph.insertNode({'id': '3', 'name': 'test 3'});
      final d = await db.graph.insertNode({'id': '4', 'name': 'test 4'});
      await db.graph.insertEdge(a.id, b.id);
      await db.graph.insertEdge(a.id, c.id);
      await db.graph.insertEdge(d.id, a.id);

      final nodes = await db.graph.traverseInbound(a.id).get();

      expect(nodes.toList(), ['1', '4']);
    });

    test('traverse outbound', () async {
      final a = await db.graph.insertNode({'id': '1', 'name': 'test 1'});
      final b = await db.graph.insertNode({'id': '2', 'name': 'test 2'});
      final c = await db.graph.insertNode({'id': '3', 'name': 'test 3'});
      final d = await db.graph.insertNode({'id': '4', 'name': 'test 4'});
      await db.graph.insertEdge(a.id, b.id);
      await db.graph.insertEdge(a.id, c.id);
      await db.graph.insertEdge(d.id, a.id);

      final nodes = await db.graph.traverseOutbound(a.id).get();

      expect(nodes.toList(), ['1', '2', '3']);
    });

    test('traverse bodies inbound', () async {
      final a = await db.graph.insertNode({'id': '1', 'name': 'test 1'});
      final b = await db.graph.insertNode({'id': '2', 'name': 'test 2'});
      final c = await db.graph.insertNode({'id': '3', 'name': 'test 3'});
      final d = await db.graph.insertNode({'id': '4', 'name': 'test 4'});
      await db.graph.insertEdge(a.id, b.id);
      await db.graph.insertEdge(a.id, c.id);
      await db.graph.insertEdge(d.id, a.id);

      final nodes = await db.graph.traverseBodiesInbound(a.id).get();

      expect(nodes[0].obj, {});
      expect(nodes[0].x, '1');
      expect(nodes[0].y, '()');

      expect(nodes[1].obj, {'id': '1', 'name': 'test 1'});
      expect(nodes[1].x, '1');
      expect(nodes[1].y, '()');

      expect(nodes[2].obj, {});
      expect(nodes[2].x, '4');
      expect(nodes[2].y, '<-');

      expect(nodes[3].obj, {'id': '4', 'name': 'test 4'});
      expect(nodes[3].x, '4');
      expect(nodes[3].y, '()');
    });

    test('traverse bodies outbound', () async {
      final a = await db.graph.insertNode({'id': '1', 'name': 'test 1'});
      final b = await db.graph.insertNode({'id': '2', 'name': 'test 2'});
      final c = await db.graph.insertNode({'id': '3', 'name': 'test 3'});
      final d = await db.graph.insertNode({'id': '4', 'name': 'test 4'});
      await db.graph.insertEdge(a.id, b.id);
      await db.graph.insertEdge(a.id, c.id);
      await db.graph.insertEdge(d.id, a.id);

      final nodes = await db.graph.traverseBodiesOutbound(a.id).get();

      expect(nodes[0].obj, {});
      expect(nodes[0].x, '1');
      expect(nodes[0].y, '()');

      expect(nodes[1].obj, {"id": "1", "name": "test 1"});
      expect(nodes[1].x, '1');
      expect(nodes[1].y, '()');

      expect(nodes[2].obj, {});
      expect(nodes[2].x, '2');
      expect(nodes[2].y, '->');
    });

    test('traverse bodies', () async {
      final a = await db.graph.insertNode({'id': '1', 'name': 'test 1'});
      final b = await db.graph.insertNode({'id': '2', 'name': 'test 2'});
      final c = await db.graph.insertNode({'id': '3', 'name': 'test 3'});
      final d = await db.graph.insertNode({'id': '4', 'name': 'test 4'});
      await db.graph.insertEdge(a.id, b.id);
      await db.graph.insertEdge(a.id, c.id);
      await db.graph.insertEdge(d.id, a.id);

      final nodes = await db.graph.traverseBodies(a.id).get();

      expect(nodes[0].obj, {});
      expect(nodes[0].x, '1');
      expect(nodes[0].y, '()');

      expect(nodes[1].obj, {"id": "1", "name": "test 1"});
      expect(nodes[1].x, '1');
      expect(nodes[1].y, '()');
    });

    test('traverse', () async {
      final a = await db.graph.insertNode({'id': '1', 'name': 'test 1'});
      final b = await db.graph.insertNode({'id': '2', 'name': 'test 2'});
      final c = await db.graph.insertNode({'id': '3', 'name': 'test 3'});
      final d = await db.graph.insertNode({'id': '4', 'name': 'test 4'});
      await db.graph.insertEdge(a.id, b.id);
      await db.graph.insertEdge(a.id, c.id);
      await db.graph.insertEdge(d.id, a.id);

      final nodes = await db.graph.traverse(a.id).get();

      expect(nodes.toList(), ['1', '4', '2', '3']);
    });
  });
}
