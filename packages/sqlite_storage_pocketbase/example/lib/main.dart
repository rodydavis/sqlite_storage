import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:sqlite_storage/sqlite_storage.dart';
import 'package:sqlite_storage_pocketbase/sqlite_storage_pocketbase.dart';

import 'connection/connection.dart';

late final DriftStorage db;
late final OfflinePocketBase client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  db = DriftStorage(connect('app.db'));
  client = await OfflinePocketBase.init('https://pocketbase.io', db);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Material(
        child: StreamBuilder(
          stream: client.offlineAuthStore.authEvents,
          builder: (context, snapshot) {
            if (snapshot.hasData) return const Example();
            return const Login();
          },
        ),
      ),
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();
  final username = TextEditingController(text: 'test@example.com');
  final password = TextEditingController(text: 'test@example.com');

  Future<void> save(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      try {
        await client
            .collection('users')
            .authWithPassword(username.text, password.text);
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error logging in: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            TextFormField(
              controller: username,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: password,
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => save(context),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  final col = client.localCollection('items');

  @override
  void dispose() {
    col.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example'),
      ),
      body: StreamBuilder<List<RecordModel>>(
        stream: col.getRecords(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No Items Found'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.getStringValue('name')),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final item = await col
              .create(body: {'name': DateTime.now().toIso8601String()});
          await col.saveRecords([item]);
        },
        tooltip: 'Add item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
