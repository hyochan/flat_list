library flat_list;

import 'package:flat_list/utils/measure_size.dart';
import 'package:flutter/material.dart';

typedef ItemBuilder<T> = Widget Function(T item, int index);

class FlatList<T> extends StatefulWidget {
  final List<T> data;
  final ItemBuilder<T> buildItem;
  final Widget? listHeaderWidget;
  final Widget? listFooterWidget;
  final Widget? listEmptyWidget;
  final Widget? listLoadingWidget;
  final bool loading;
  final int numColumns;
  final double onEndReachedDelta;
  final VoidCallback? onEndReached;
  final Function(double, double)? onScroll;

  /// Below props for grid view
  final double childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const FlatList({
    super.key,
    required this.data,
    required this.buildItem,
    this.listHeaderWidget,
    this.listFooterWidget,
    this.listEmptyWidget,
    this.listLoadingWidget,
    this.loading = false,
    this.numColumns = 1,
    this.onEndReachedDelta = 200,
    this.onEndReached,
    this.onScroll,
    this.childAspectRatio = 1,
    this.mainAxisSpacing = 10,
    this.crossAxisSpacing = 10,
  });

  @override
  State<FlatList> createState() => _FlatListState<T>();
}

var defaultLoadingWidget = Container(
  padding: const EdgeInsets.all(20),
  child: const Center(
    child: CircularProgressIndicator(),
  ),
);

class _FlatListState<T> extends State<FlatList> {
  var _height = 0.0;
  var _currentSize = 0;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    double maxScroll = _scrollController.position.maxScrollExtent;
    double currentScroll = _scrollController.position.pixels;
    double delta = widget.onEndReachedDelta;
    if (maxScroll - currentScroll <= delta &&
        _currentSize < widget.data.length) {
      setState(() => _currentSize = widget.data.length);
      widget.onEndReached?.call();
    }

    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels != 0) {
        widget.onEndReached?.call();
      }
    }

    widget.onScroll?.call(maxScroll, currentScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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

    /// Render [GridView]
    if (widget.numColumns > 1) {
      if (_height == 0.0) {
        return MeasureSize(
          onChange: (size) {
            setState(() => _height = size.height + 20);
          },
          child: widget.buildItem(widget.data[0], 0),
        );
      }

      return CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          widget.listHeaderWidget != null
              ? SliverToBoxAdapter(child: widget.listHeaderWidget!)
              : const SliverToBoxAdapter(child: SizedBox()),
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.numColumns,
              mainAxisExtent: _height,
              childAspectRatio: widget.childAspectRatio,
              mainAxisSpacing: widget.mainAxisSpacing,
              crossAxisSpacing: widget.crossAxisSpacing,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                var item = widget.data[index];
                return widget.buildItem(item, widget.data.indexOf(item));
              },
              childCount: widget.data.length,
            ),
          ),
          widget.loading
              ? SliverToBoxAdapter(
                  child: widget.listLoadingWidget ?? defaultLoadingWidget)
              : const SliverToBoxAdapter(child: SizedBox()),
          widget.listFooterWidget != null
              ? SliverToBoxAdapter(child: widget.listFooterWidget!)
              : const SliverToBoxAdapter(child: SizedBox()),
        ],
      );
    }

    /// Render [ListView]
    return ListView.builder(
      controller: _scrollController,
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
              widget.loading
                  ? widget.listLoadingWidget ?? defaultLoadingWidget
                  : const SizedBox(),
              widget.listFooterWidget ?? const SizedBox(),
            ],
          );
        }

        return widget.buildItem(item, index);
      },
    );
  }
}
