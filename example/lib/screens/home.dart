import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Home extends HookWidget {
  static const name = 'home';
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: ListView.builder(
        itemCount: 2,
        itemBuilder: ((context, index) => ListTile(
              title: Text('FlatList Example ${index + 1}'),
              onTap: () {
                Navigator.of(context).pushNamed('/flat-list-ex${index + 1}');
              },
            )),
      ),
    );
  }
}
