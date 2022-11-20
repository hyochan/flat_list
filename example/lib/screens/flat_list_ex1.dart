import 'package:flat_list/flat_list.dart';
import 'package:flat_list_example/common_views.dart';
import 'package:flat_list_example/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class FlatListEx1 extends HookWidget {
  static const name = '/flat-list-ex1';
  const FlatListEx1({super.key});

  @override
  Widget build(BuildContext context) {
    var items = useState(data);
    var loading = useState(false);

    /// Note: You can either provide controller by yourself
    /// and gain the full control of the list or the grid view.
    var scrollController = useScrollController();

    // ignore: unused_element
    void onScroll() {
      double maxScroll = scrollController.position.maxScrollExtent;
      double currentScroll = scrollController.position.pixels;

      // ignore: avoid_print
      print('maxScroll: $maxScroll');
      // ignore: avoid_print
      print('currentScroll: $currentScroll');
    }

    useEffect(() {
      // Remove comment to gain full control of the list or the grid view.
      // scrollController.addListener(onScroll);

      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Example'),
      ),
      body: SafeArea(
        child: FlatList(
          loading: loading.value,
          onEndReached: () async {
            loading.value = true;
            await Future.delayed(const Duration(seconds: 2));
            if (context.mounted) {
              items.value += getMoreData();
              loading.value = false;
            }
          },
          controller: scrollController,
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
          itemSeparatorWidget:
              const Divider(color: Colors.blueAccent, height: 1),
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
