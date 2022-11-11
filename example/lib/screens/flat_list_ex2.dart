import 'package:flat_list/flat_list.dart';
import 'package:flat_list_example/common_views.dart';
import 'package:flat_list_example/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class FlatListEx2 extends HookWidget {
  static const name = '/flat-list-ex2';
  const FlatListEx2({super.key});

  @override
  Widget build(BuildContext context) {
    var items = useState(data);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grid Example'),
      ),
      body: SafeArea(
        child: FlatList(
          onEndReached: () {
            items.value += getMoreData();
          },
          numColumns: 2,
          listHeaderWidget: const Header(),
          listFooterWidget: const Footer(),
          listEmptyWidget: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(12),
            child: const Text('List is empty!'),
          ),
          data: items.value,
          buildItem: (item, index) {
            var person = items.value[index];

            return ListItemView(person: person);
          },
        ),
      ),
    );
  }
}
