import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqlite_storage/sqlite_storage.dart';

import 'database_viewer.dart';

class DatabaseViewerLauncher extends StatelessWidget {
  const DatabaseViewerLauncher({
    super.key,
    required this.database,
    this.enabled = kDebugMode,
  });

  final bool enabled;
  final Database database;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();
    return TextButton(
      child: const Text('Open Database Viewer'),
      onPressed: () {
        final nav = Navigator.of(context, rootNavigator: true);
        nav.push<void>(
          MaterialPageRoute(
            builder: (context) => DatabaseViewer(database: database),
            fullscreenDialog: true,
          ),
        );
      },
    );
  }
}
