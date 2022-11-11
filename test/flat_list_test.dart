import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flat_list/flat_list.dart';

void main() {
  testWidgets('Rendering', (WidgetTester tester) async {
    final flatList = FlatList(
      listEmptyWidget: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12),
        child: const Text('List is empty!'),
      ),
      data: const [1, 2, 3, 4, 5],
      buildItem: (item, index) {
        return Text('num $item');
      },
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Container(
          child: flatList,
        ),
      ),
    ));

    expect(find.byWidget(flatList), findsOneWidget);
  });
}
