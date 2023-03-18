library flat_list;

import 'package:flutter/material.dart';
import 'package:flat_list/utils/measure_size.dart' show MeasureSize;
import 'package:flutter/foundation.dart' show kReleaseMode;

/// Define generic type T for the list item.
typedef ItemBuilder<T> = Widget Function(T item, int index);

/// Root of the FlatList widget tree.
class FlatList<T> extends StatefulWidget {
  /// The `required` parameter that specifies the data source for the list.
  final List<T> data;

  /// The `required` parameter that specifies the widget builder for the list item.
  final ItemBuilder<T> buildItem;

  /// The header widget to render which is scrollable with list item.
  final Widget? listHeaderWidget;

  /// The footer widget to render which is scrollable with list item.
  final Widget? listFooterWidget;

  /// The widget to render when the list is empty.
  final Widget? listEmptyWidget;

  /// The widget to render when the list is loading.
  /// The loading will be available at the bottom of the list.
  final Widget? listLoadingWidget;

  /// The list separator that attaches to bottom each list item.
  final Widget? itemSeparatorWidget;

  /// The `loading` state value.
  final bool loading;

  /// The parameter to specify when [onEndReached] should be called.
  ///
  /// The default value is 200 and when user reaches 200 pixels from the bottom of the list,
  /// it will fire `onEndReached` callback.
  final double onEndReachedDelta;

  /// The callback when user reaches the bottom of the list.
  final VoidCallback? onEndReached;

  /// The callback when user scrolls.
  /// It returns [maxScroll] and [currentScroll] as parameters.
  final Function(double maxScroll, double currentScroll)? onScroll;

  /// When you want to provide full controls over the list,
  /// you can pass [controller] to the FlatList.
  ///
  /// It will have abilities to [animateTo], [jumpTo] and more that exists in [ScrollController].
  final ScrollController? controller;

  /// Invert the scroll direction. This argument is often used when you are building a chat list.
  final bool inverted;

  /// Only works when [horizontal] is `true`.
  final int numColumns;

  /// Make horizontal list view when value is `true`.
  final bool horizontal;

  /// RefreshControl props
  /// The callback when user pulls the list to refresh.
  final RefreshCallback? onRefresh;

  /// The color of the refresh indicator.
  final Color? refreshIndicatorColor;

  /// The color of the refresh indicator's stroke.
  final double refreshIndicatorStrokeWidth;

  // Below props for grid view
  // The aspect ratio of the list for [GridView].
  final double childAspectRatio;
  // The main axis spacing between children for [GridView].
  final double mainAxisSpacing;
  // The cross axis spacing between children for [GridView].
  final double crossAxisSpacing;

  const FlatList({
    super.key,
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
    this.onRefresh,
    this.refreshIndicatorColor,
    this.refreshIndicatorStrokeWidth = 2.0,
    this.childAspectRatio = 1,
    this.mainAxisSpacing = 10,
    this.crossAxisSpacing = 10,
    this.horizontal = false,
    this.controller,
    this.inverted = false,
  });

  @override
  State<FlatList> createState() => _FlatListState<T>();
}

/// The default loading widget.
var defaultLoadingWidget = Container(
  padding: const EdgeInsets.all(20),
  child: const Center(
    child: CircularProgressIndicator(),
  ),
);

class _FlatListState<T> extends State<FlatList<T>> {
  var _height = 0.0;
  var _currentSize = 0;
  var _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _scrollController = widget.controller!;
    }

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_scrollController.positions.isNotEmpty && _hasScrolledPast()) {
        _onEndReachedCallback();
      }
    });
  }

  void _onEndReachedCallback() {
    if (!widget.loading) {
      widget.onEndReached?.call();
    }
  }

  void _onScroll() {
    if (_hasScrolledPast()) {
      setState(() => _currentSize = widget.data.length);
      _onEndReachedCallback();
    }

    if (_isAtEdge()) {
      _onEndReachedCallback();
    }

    double maxScroll = _scrollController.position.maxScrollExtent;
    double currentScroll = _scrollController.position.pixels;

    widget.onScroll?.call(maxScroll, currentScroll);
  }

  bool _hasScrolledPast() {
    double maxScroll = _scrollController.position.maxScrollExtent;
    double currentScroll = _scrollController.position.pixels;
    double delta = widget.onEndReachedDelta;

    return maxScroll - currentScroll <= delta && _currentSize < widget.data.length;
  }

  bool _isAtEdge() {
    return _scrollController.position.atEdge && _scrollController.position.pixels != 0;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildList(BuildContext context) {
    if (widget.data.isEmpty) {
      return ListView(
        reverse: false,
        scrollDirection: widget.horizontal ? Axis.horizontal : Axis.vertical,
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
          throw Exception('[numColumns] is not supported with horizontal list.');
        }

        if (widget.itemSeparatorWidget != null) {
          throw Exception('[itemSeparatorWidget] only works with horizontal list.');
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

      /// Render [GridView]
      return CustomScrollView(
        reverse: false,
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
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
          widget.listFooterWidget != null
              ? SliverToBoxAdapter(child: widget.listFooterWidget!)
              : const SliverToBoxAdapter(child: SizedBox()),
          widget.loading
              ? SliverToBoxAdapter(child: widget.listLoadingWidget ?? defaultLoadingWidget)
              : const SliverToBoxAdapter(child: SizedBox()),
        ],
      );
    }

    /// Render [ListView]
    return CustomScrollView(
      reverse: false,
      scrollDirection: widget.horizontal ? Axis.horizontal : Axis.vertical,
      physics: const AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              var item = widget.data[index];

              // The `header` and `footer` will be ignored when rendering horizontal list.
              if (!widget.horizontal) {
                if (index == widget.data.length - 1) {
                  return Column(
                    key: ValueKey(item),
                    children: [
                      /// Render header widget only when the items length is 1
                      widget.data.length == 1
                          ? widget.listHeaderWidget ?? const SizedBox()
                          : const SizedBox(),

                      widget.buildItem(item, index),
                      widget.itemSeparatorWidget ?? const SizedBox(),
                      widget.listFooterWidget ?? const SizedBox(),
                      widget.loading
                          ? widget.listLoadingWidget ?? defaultLoadingWidget
                          : const SizedBox(),
                    ],
                  );
                }

                if (index == 0) {
                  return Column(
                    key: ValueKey(item),
                    children: [
                      widget.listHeaderWidget ?? const SizedBox(),
                      widget.buildItem(item, index),
                      widget.itemSeparatorWidget ?? const SizedBox(),
                    ],
                  );
                }
              }

              return Column(
                key: ValueKey(item),
                children: [
                  widget.buildItem(item, index),
                  widget.itemSeparatorWidget ?? const SizedBox(),
                ],
              );
            },
            childCount: widget.data.length,
          ),
        )
      ],
    );
  }

  /// When [inverted] is true, the list will be rendered from bottom to top.
  ///
  /// It would be better to separate the build functions
  /// before we actually abstract all functionalities to make code stable and clear.
  Widget _buildInvertedList(BuildContext context) {
    if (widget.data.isEmpty) {
      return ListView(
        reverse: true,
        scrollDirection: widget.horizontal ? Axis.horizontal : Axis.vertical,
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
          throw Exception('[numColumns] is not supported with horizontal list.');
        }

        if (widget.itemSeparatorWidget != null) {
          throw Exception('[itemSeparatorWidget] only works with [numColumn=1] list.');
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

      /// Render reversed [GridView]
      return CustomScrollView(
        reverse: true,
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
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
                return KeyedSubtree(
                  key: ValueKey(item),
                  child: widget.buildItem(item, widget.data.indexOf(item)),
                );
              },
              childCount: widget.data.length,
            ),
          ),
          widget.listFooterWidget != null
              ? SliverToBoxAdapter(child: widget.listFooterWidget!)
              : const SliverToBoxAdapter(child: SizedBox()),
          widget.loading
              ? SliverToBoxAdapter(child: widget.listLoadingWidget ?? defaultLoadingWidget)
              : const SliverToBoxAdapter(child: SizedBox()),
        ],
      );
    }

    /// Render reversed [ListView]
    return CustomScrollView(
      reverse: true,
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
                if (index == widget.data.length - 1) {
                  return Column(
                    key: ValueKey(item),
                    children: [
                      widget.loading
                          ? widget.listLoadingWidget ?? defaultLoadingWidget
                          : const SizedBox(),
                      widget.listFooterWidget ?? const SizedBox(),
                      widget.itemSeparatorWidget ?? const SizedBox(),
                      widget.buildItem(item, index),

                      /// Render header widget only when the items length is 1
                      widget.data.length == 1
                          ? widget.listHeaderWidget ?? const SizedBox()
                          : const SizedBox(),
                    ],
                  );
                }

                if (index == 0) {
                  return Column(
                    key: ValueKey(item),
                    children: [
                      widget.itemSeparatorWidget ?? const SizedBox(),
                      widget.buildItem(item, index),
                      widget.listHeaderWidget ?? const SizedBox(),
                    ],
                  );
                }
              }

              return Column(
                key: ValueKey(item),
                children: [
                  widget.itemSeparatorWidget ?? const SizedBox(),
                  widget.buildItem(item, index),
                ],
              );
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
        child: !widget.inverted ? _buildList(context) : _buildInvertedList(context),
      );
    }
    return !widget.inverted ? _buildList(context) : _buildInvertedList(context);
  }
}
