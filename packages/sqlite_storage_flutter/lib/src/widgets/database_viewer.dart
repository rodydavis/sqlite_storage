import 'package:flutter/material.dart';
import 'package:sqlite_storage/sqlite_storage.dart';

class DatabaseViewer extends StatelessWidget {
  const DatabaseViewer({super.key, required this.database});

  final Database database;

  @override
  Widget build(BuildContext context) {
    final daos = <Dao, (String, Widget)>{
      database.kv: ('Key/Value', KeyValueViewer(database: database.kv)),
    };
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Viewer'),
      ),
      body: ListView(
        children: [
          for (final dao in daos.entries)
            ListTile(
              title: Text(dao.value.$1),
              onTap: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (context) => dao.value.$2,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class KeyValueViewer extends StatelessWidget {
  const KeyValueViewer({super.key, required this.database});

  final KeyValueDatabase database;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Key/Value Database'),
      ),
      body: StreamBuilder<Map<String, Object?>>(
        stream: database.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final data = snapshot.data!.entries;
          return SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Key')),
                  DataColumn(label: Text('Value')),
                ],
                rows: [
                  for (final entry in data)
                    DataRow(
                      cells: [
                        DataCell(Text(entry.key)),
                        DataCell(Text(entry.value.toString())),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// TODO: Custom tables
// TODO: AI assistant
// TODO: Custom queries
