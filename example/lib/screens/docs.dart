import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sqlite_storage/sqlite_storage.dart';

import '../main.dart';

class Docs extends StatefulWidget {
  const Docs({super.key, required this.collection});

  final Collection collection;

  factory Docs.example() {
    return Docs(
      collection: db.docs.collection('test'),
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
                  final nav = Navigator.of(context);
                  nav.push(MaterialPageRoute(
                    builder: (context) => DocumentEdit(doc: doc),
                    fullscreenDialog: true,
                  ));
                },
              );
            },
          );
        },
      ),
    );
  }
}

class DocumentEdit extends StatefulWidget {
  const DocumentEdit({super.key, required this.doc});

  final DocumentSnapshot doc;

  @override
  State<DocumentEdit> createState() => _DocumentEditState();
}

class _DocumentEditState extends State<DocumentEdit> {
  static const encoder = JsonEncoder.withIndent(' ');
  late final controller = TextEditingController(
    text: encoder.convert(widget.doc.data),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doc: ${widget.doc.path}'),
        actions: [
          IconButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final nav = Navigator.of(context);
              try {
                final data = jsonDecode(controller.text.trim());
                await widget.doc.set(data);
                nav.pop();
              } catch (e) {
                messenger.hideCurrentSnackBar();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Error saving document: $e'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: TextField(
          maxLines: null,
          controller: controller,
          expands: true,
        ),
      ),
    );
  }
}
