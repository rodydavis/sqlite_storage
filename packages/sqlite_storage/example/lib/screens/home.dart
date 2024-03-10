import 'package:flutter/material.dart';

import '../main.dart';
import 'counter.dart';
import 'docs.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          AnimatedBuilder(
              animation: brightness,
              builder: (context, _) {
                return DropdownButton<ThemeMode>(
                  value: brightness.value,
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark'),
                    ),
                  ],
                  onChanged: (value) {
                    brightness.value = value!;
                  },
                );
              }),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Counter'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const Counter();
                  },
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Documents'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return Docs.example();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
