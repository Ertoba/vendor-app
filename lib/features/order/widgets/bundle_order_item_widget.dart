import 'package:flutter/material.dart';
import 'package:sixam_mart_store/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_store/features/order/domain/models/order_details_model.dart';
import 'package:sixam_mart_store/helper/price_converter_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';

class BundleOrderItemGroup {
  final String groupId;
  final List<OrderDetailsModel> items;
  const BundleOrderItemGroup({required this.groupId, required this.items});
}

List<Object> groupBundleOrderDetails(List<Object> items) {
  final List<Object> result = [];
  final Map<String, BundleOrderItemGroup> groupsById = {};

  for (final Object entry in items) {
    if (entry is! OrderDetailsModel || !entry.isBundleItem) {
      result.add(entry);
      continue;
    }

    final String groupId = entry.bundleGroupId!;
    BundleOrderItemGroup? group = groupsById[groupId];
    if (group == null) {
      final List<OrderDetailsModel> groupItems = [];
      group = BundleOrderItemGroup(groupId: groupId, items: groupItems);
      groupsById[groupId] = group;
      result.add(group);
    }
    group.items.add(entry);
  }

  return result;
}

class BundleOrderItemWidget extends StatelessWidget {
  final BundleOrderItemGroup group;
  const BundleOrderItemWidget({super.key, required this.group});

  static const int _visibleThumbnails = 3;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final OrderDetailsModel primary = group.items.first;

    final List<String> images = group.items.map((item) => item.itemDetails?.imageFullUrl ?? '').toList();

    final double finalPrice = group.items.fold(0.0, (sum, item) => sum + ((item.price ?? 0) * (item.quantity ?? 1)));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Text(
        primary.bundleName ?? '',
        maxLines: 1, overflow: TextOverflow.ellipsis,
        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),

      Row(children: [

        BundleThumbnailStrip(images: images, totalCount: group.items.length, maxVisible: _visibleThumbnails),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        Text(
          PriceConverterHelper.convertPrice(finalPrice),
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
        ),

      ]),

    ]);
  }
}

class BundleThumbnailStrip extends StatelessWidget {
  final List<String> images;
  final int totalCount;
  final int maxVisible;

  static const double _size = 48;
  static const double _overlap = 15;

  const BundleThumbnailStrip({super.key, required this.images, required this.totalCount, required this.maxVisible});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final List<String> shown = images.isEmpty ? const [''] : images;
    final int visibleCount = shown.length < maxVisible ? shown.length : maxVisible;
    final int hiddenCount = totalCount - visibleCount;
    final bool showCounter = hiddenCount > 0;
    final int circleCount = visibleCount + (showCounter ? 1 : 0);
    final double step = _size - _overlap;

    return SizedBox(
      height: _size,
      width: _size + step * (circleCount - 1),
      child: Stack(children: List.generate(circleCount, (index) {
        final bool isCounter = showCounter && index == visibleCount;

        return Positioned(
          left: step * index,
          child: Material(
            borderRadius: BorderRadius.circular(_size / 2),
            child: Container(
              height: _size, width: _size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.disabledColor.withAlpha(50),
                border: isCounter ? null : Border.all(color: theme.cardColor, width: 1.5),
              ),
              alignment: Alignment.center,
              clipBehavior: Clip.antiAlias,
              child: isCounter ? Text(
                '+$hiddenCount',
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
              ) : ClipOval(child: CustomImageWidget(image: shown[index], height: _size, width: _size, fit: BoxFit.fill)),
            ),
          ),
        );
      })),
    );
  }
}
