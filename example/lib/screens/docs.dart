import 'package:flutter/material.dart';
import 'package:sqlite_storage/sqlite_storage.dart';

import '../main.dart';

class Docs extends StatefulWidget {
  const Docs({super.key, required this.collection});

  final Collection collection;

  factory Docs.example() {
    return Docs(
      collection: db.documents.collection('test'),
    );
  }

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
