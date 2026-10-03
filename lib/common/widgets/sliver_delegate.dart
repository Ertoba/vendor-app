import 'package:flutter/material.dart';

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  final double height;
  // Optional value representing the data this header's content actually depends on.
  // When provided (by both the old and new delegate), shouldRebuild compares this
  // instead of `child`, since `child` is a freshly-built widget every call and thus
  // never == to the previous one, making the old comparison always true.
  final Object? rebuildKey;

  SliverDelegate({required this.child, required this.height, this.rebuildKey});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: height,
        child: child);
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    if (oldDelegate.maxExtent != height || oldDelegate.minExtent != height) return true;
    if (rebuildKey != null || oldDelegate.rebuildKey != null) {
      return rebuildKey != oldDelegate.rebuildKey;
    }
    return child != oldDelegate.child;
  }
}
