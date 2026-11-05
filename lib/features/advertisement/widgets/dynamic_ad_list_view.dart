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
  final String? placementCode;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool shrinkWrap;
  final Axis scrollDirection;
  final AdLayout adLayout;
  final double? adHeight;

  const DynamicAdListView.builder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorBuilder,
    this.route,
    this.adInterval,
    this.placementCode,
    this.physics,
    this.padding,
    this.controller,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
    this.adLayout = AdLayout.card,
    this.adHeight,
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
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      separatorBuilder: (context, index) {
        final regularSeparator = separatorBuilder != null
            ? separatorBuilder!(context, index)
            : const SizedBox(height: 8);

        return DynamicAdSeparator(
          index: index,
          route: route,
          interval: adInterval,
          placementCode: placementCode,
          regularSeparator: regularSeparator,
          layout: adLayout,
          height: adHeight,
        );
      },
    );
  }
}

