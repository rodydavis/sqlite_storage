import 'package:flutter/material.dart';

import '../main.dart';

class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterExampleState();
}

class _CounterExampleState extends State<Counter> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    db.track.sendScreenView('home');
    db.kv.$int.watch('counter').listen((value) {
      if (mounted) {
        setState(() {
          _counter = value ?? 0;
        });
      }
    });
  }

  void _incrementCounter() {
    db.kv.$int.set('counter', _counter + 1);
    db.track.sendEvent('counter', 'increment');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
