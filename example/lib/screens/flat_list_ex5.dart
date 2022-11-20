import 'package:flat_list/flat_list.dart';
import 'package:flat_list_example/common_views.dart';
import 'package:flat_list_example/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class FlatListEx5 extends HookWidget {
  const FlatListEx5({super.key});

  @override
  Widget build(BuildContext context) {
    var items = useState(data);
    var loading = useState(false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inverted GridView'),
      ),
      body: SafeArea(
        child: FlatList(
          numColumns: 2,
          inverted: true,
          loading: loading.value,
          onEndReached: () async {
            loading.value = true;
            await Future.delayed(const Duration(seconds: 2));
            if (context.mounted) {
              items.value += getMoreData();
              loading.value = false;
            }
          },
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2));

            if (context.mounted) {
              items.value = data;
            }
          },
          listHeaderWidget: const Header(),
          listFooterWidget: const Footer(),
          listEmptyWidget: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(12),
            child: const Text('List is empty!'),
          ),
          // itemSeparatorWidget:
          //     const Divider(color: Colors.blueAccent, height: 1),
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
