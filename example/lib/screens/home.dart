import 'package:flat_list_example/routes.dart';
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
        itemCount: routes.length - 1,
        itemBuilder: ((context, index) => ListTile(
              // Subtract [Home] screen count from [routes] length.
              title: Text('FlatList Example ${index + 1}'),
              onTap: () {
                Navigator.of(context).pushNamed('/flat-list-ex${index + 1}');
              },
            )),
      ),
    );
  }
}
