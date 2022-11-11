library flat_list;

import 'package:flat_list/utils/measure_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef ItemBuilder<T> = Widget Function(T item, int index);

class FlatList<T> extends StatefulWidget {
  final List<T> data;
  final ItemBuilder<T> buildItem;
  final Widget? listHeaderWidget;
  final Widget? listFooterWidget;
  final Widget? listEmptyWidget;
  final int numColumns;

  const FlatList({
    super.key,
    required this.data,
    required this.buildItem,
    this.listHeaderWidget,
    this.listFooterWidget,
    this.listEmptyWidget,
    this.numColumns = 1,
  });

  @override
  State<FlatList> createState() => _FlatListState();
}

class _FlatListState extends State<FlatList> {
  var height = 0.0;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return ListView(
        children: [
          widget.listHeaderWidget ?? const SizedBox(),
          widget.listEmptyWidget ?? const SizedBox(),
          widget.listFooterWidget ?? const SizedBox(),
        ],
      );
    }

    if (widget.numColumns > 1) {
      if (height == 0.0) {
        return MeasureSize(
          onChange: (size) {
            setState(() => height = size.height + 20);
          },
          child: widget.buildItem(widget.data[0], 0),
        );
      }

      return CustomScrollView(
        slivers: <Widget>[
          widget.listHeaderWidget != null
              ? SliverToBoxAdapter(child: widget.listHeaderWidget!)
              : const SliverToBoxAdapter(child: SizedBox()),
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.numColumns,
              mainAxisExtent: height,
              childAspectRatio: 1,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                var item = widget.data[index];
                return widget.buildItem(item, widget.data.indexOf(item));
              },
              childCount: widget.data.length,
            ),
          ),
          widget.listFooterWidget != null
              ? SliverToBoxAdapter(child: widget.listFooterWidget!)
              : const SliverToBoxAdapter(child: SizedBox()),
        ],
      );
    }

    return ListView.builder(
      itemCount: widget.data.length,
      itemBuilder: (context, index) {
        var item = widget.data[index];

        if (index == 0) {
          return Column(
            children: [
              widget.listHeaderWidget ?? const SizedBox(),
              widget.buildItem(item, index),
            ],
          );
        }

        if (index == widget.data.length - 1) {
          return Column(
            children: [
              widget.buildItem(item, index),
              widget.listFooterWidget ?? const SizedBox(),
            ],
          );
        }

        return widget.buildItem(item, index);
      },
    );
  }
}
