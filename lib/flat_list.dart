library flat_list;

import 'package:flutter/material.dart';
import 'package:flat_list/utils/measure_size.dart' show MeasureSize;
import 'package:flutter/foundation.dart' show kReleaseMode;

typedef ItemBuilder<T> = Widget Function(T item, int index);

class FlatList<T> extends StatefulWidget {
  final Key? scrollViewKey;
  final List<T> data;
  final ItemBuilder<T> buildItem;
  final Widget? listHeaderWidget;
  final Widget? listFooterWidget;
  final Widget? listEmptyWidget;
  final Widget? listLoadingWidget;
  final Widget? itemSeparatorWidget;
  final bool loading;
  final double onEndReachedDelta;
  final VoidCallback? onEndReached;
  final Function(double, double)? onScroll;

  /// Only works when [horizontal] is true.
  final int numColumns;
  final bool horizontal;

  /// RefreshControl props
  final Key? refreshIndicatorKey;
  final RefreshCallback? onRefresh;
  final Color? refreshIndicatorColor;
  final double refreshIndicatorStrokeWidth;

  /// Below props for grid view
  final Key? gridViewKey;
  final double childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const FlatList({
    super.key,
    this.scrollViewKey,
    required this.data,
    required this.buildItem,
    this.listHeaderWidget,
    this.listFooterWidget,
    this.listEmptyWidget,
    this.listLoadingWidget,
    this.itemSeparatorWidget,
    this.loading = false,
    this.numColumns = 1,
    this.onEndReachedDelta = 200,
    this.onEndReached,
    this.onScroll,
    this.refreshIndicatorKey,
    this.onRefresh,
    this.refreshIndicatorColor,
    this.refreshIndicatorStrokeWidth = 2.0,
    this.gridViewKey,
    this.childAspectRatio = 1,
    this.mainAxisSpacing = 10,
    this.crossAxisSpacing = 10,
    this.horizontal = false,
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

  void _onEndReachedCallback() {
    if (!widget.loading) {
      widget.onEndReached?.call();
    }
  }

  void _onScroll() {
    double maxScroll = _scrollController.position.maxScrollExtent;
    double currentScroll = _scrollController.position.pixels;
    double delta = widget.onEndReachedDelta;
    if (maxScroll - currentScroll <= delta &&
        _currentSize < widget.data.length) {
      setState(() => _currentSize = widget.data.length);
      _onEndReachedCallback();
    }

    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels != 0) {
        _onEndReachedCallback();
      }
    }

    widget.onScroll?.call(maxScroll, currentScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildList(BuildContext context) {
    if (widget.data.isEmpty) {
      return ListView(
        scrollDirection: widget.horizontal ? Axis.horizontal : Axis.vertical,
        key: widget.scrollViewKey,
        children: [
          widget.listHeaderWidget ?? const SizedBox(),
          widget.listEmptyWidget ?? const SizedBox(),
          widget.listFooterWidget ?? const SizedBox(),
        ],
      );
    }

    /// Render [GridView]
    if (widget.numColumns > 1) {
      if (!kReleaseMode) {
        if (widget.horizontal) {
          throw Exception(
              '[numColumns] is not supported with horizontal list.');
        }

        if (widget.itemSeparatorWidget != null) {
          throw Exception(
              '[itemSeparatorWidget] only works with horizontal list.');
        }
      }

      if (_height == 0.0) {
        return MeasureSize(
          onChange: (size) {
            setState(() => _height = size.height + 20);
          },
          child: widget.buildItem(widget.data[0], 0),
        );
      }

      return CustomScrollView(
        key: widget.scrollViewKey,
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          widget.listHeaderWidget != null
              ? SliverToBoxAdapter(child: widget.listHeaderWidget!)
              : const SliverToBoxAdapter(child: SizedBox()),
          SliverGrid(
            key: widget.gridViewKey,
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
          widget.listFooterWidget != null
              ? SliverToBoxAdapter(child: widget.listFooterWidget!)
              : const SliverToBoxAdapter(child: SizedBox()),
          widget.loading
              ? SliverToBoxAdapter(
                  child: widget.listLoadingWidget ?? defaultLoadingWidget)
              : const SliverToBoxAdapter(child: SizedBox()),
        ],
      );
    }

    /// Render [ListView]
    return CustomScrollView(
      key: widget.scrollViewKey,
      scrollDirection: widget.horizontal ? Axis.horizontal : Axis.vertical,
      physics: const BouncingScrollPhysics(),
      controller: _scrollController,
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              var item = widget.data[index];

              // The `header` and `footer` will be ignored when rendering horizontal list.
              if (!widget.horizontal) {
                if (index == 0) {
                  return Column(
                    children: [
                      widget.listHeaderWidget ?? const SizedBox(),
                      widget.buildItem(item, index),
                      widget.itemSeparatorWidget ?? const SizedBox(),
                    ],
                  );
                }

                if (index == widget.data.length - 1) {
                  return Column(
                    children: [
                      widget.buildItem(item, index),
                      widget.itemSeparatorWidget ?? const SizedBox(),
                      widget.listFooterWidget ?? const SizedBox(),
                      widget.loading
                          ? widget.listLoadingWidget ?? defaultLoadingWidget
                          : const SizedBox(),
                    ],
                  );
                }
              }

              return Column(children: [
                widget.buildItem(item, index),
                widget.itemSeparatorWidget ?? const SizedBox(),
              ]);
            },
            childCount: widget.data.length,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh!,
        color: widget.refreshIndicatorColor,
        strokeWidth: widget.refreshIndicatorStrokeWidth,
        key: widget.refreshIndicatorKey,
        child: _buildList(context),
      );
    }
    return _buildList(context);
  }
}
