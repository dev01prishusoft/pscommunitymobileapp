import 'package:flutter/material.dart';
import 'advertisement_card.dart';
import 'dynamic_ad_separator.dart';

/// A drop-in replacement for [ListView.builder] that automatically injects
/// advertisement cards between list items based on backend route configurations.
///
/// Example:
/// ```dart
/// DynamicAdListView.builder(
///   itemCount: items.length,
///   itemBuilder: (context, index) => MemberCard(items[index]),
/// )
/// ```
class DynamicAdListView extends StatelessWidget {
  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;
  final Widget Function(BuildContext, int)? separatorBuilder;
  final String? route;
  final int? adInterval;
  final int? adIndex;
  final bool repeatAds;
  final String? placementCode;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool shrinkWrap;
  final Axis scrollDirection;
  final AdLayout adLayout;
  final double? adHeight;
  final bool? primary;
  final bool reverse;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final Clip clipBehavior;

  const DynamicAdListView.builder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorBuilder,
    this.route,
    this.adInterval,
    this.adIndex,
    this.repeatAds = false,
    this.placementCode,
    this.physics,
    this.padding,
    this.controller,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
    this.adLayout = AdLayout.card,
    this.adHeight,
    this.primary,
    this.reverse = false,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.clipBehavior = Clip.hardEdge,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 0) {
      return const SizedBox.shrink();
    }

    return ListView.separated(
      controller: controller,
      physics: physics,
      padding: padding,
      shrinkWrap: shrinkWrap,
      scrollDirection: scrollDirection,
      reverse: reverse,
      primary: primary,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      // ignore: deprecated_member_use
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      separatorBuilder: (context, index) {
        final regularSeparator = separatorBuilder != null
            ? separatorBuilder!(context, index)
            : (scrollDirection == Axis.horizontal
                  ? const SizedBox(width: 8)
                  : const SizedBox(height: 8));

        return DynamicAdSeparator(
          index: index,
          route: route,
          interval: adInterval,
          adIndex: adIndex,
          repeat: repeatAds,
          placementCode: placementCode,
          regularSeparator: regularSeparator,
          layout: adLayout,
          height: adHeight,
        );
      },
    );
  }
}

