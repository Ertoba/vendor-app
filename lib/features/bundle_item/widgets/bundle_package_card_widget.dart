part of '../screens/bundle_package_list_screen.dart';

/// One row of the package list: the name, a strip of the items it contains, the
/// discounted price against what those items cost separately, and the actions
/// menu.
class _BundlePackageCard extends StatelessWidget {
  final BundlePackage bundle;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// How many thumbnails the strip shows before the rest become a "+n".
  static const int _visibleThumbnails = 3;

  const _BundlePackageCard({required this.bundle, required this.onTap, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double basePrice = bundle.basePrice ?? 0;
    final double finalPrice = bundle.price;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Row(children: [
            Expanded(child: Text(
              bundle.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
            )),

            /// Status and window folded into one label by the server — rendered,
            /// not recomputed.
            if((bundle.visibilityStatus ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                child: Text(
                  bundle.visibilityStatus!.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: theme.hintColor),
                ),
              ),

            CustomPopupMenuButton(
              items: [
                MenuItem('edit'.tr, Icons.edit, 0, theme.primaryColor),
                MenuItem('delete'.tr, Icons.delete, 1, theme.colorScheme.error),
              ],
              onSelected: (value) => value == 0 ? onEdit() : onDelete(),
              child: Container(
                height: 30, width: 30,
                decoration: BoxDecoration(
                  color: theme.disabledColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(color: theme.disabledColor.withValues(alpha: 0.05)),
                ),
                child: Icon(Icons.more_vert, size: 18, color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.7)),
              ),
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Row(children: [

            _ThumbnailStrip(
              images: bundle.cardImages,
              totalCount: bundle.isShowingOwnThumbnail ? 1 : (bundle.itemCount ?? bundle.itemImages.length),
              maxVisible: _visibleThumbnails,
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            Text(
              PriceConverterHelper.convertPrice(finalPrice),
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
            ),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

            /// Only worth showing when the bundle actually saves the customer
            /// something — an undiscounted package would print the same figure twice.
            if(basePrice > finalPrice)
              Text(
                PriceConverterHelper.convertPrice(basePrice),
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: theme.hintColor,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: theme.hintColor,
                ),
              ),

          ]),

        ]),
      ),
    );
  }
}

/// The overlapping circular thumbnails on a package card, with a "+n" chip
/// standing in for whatever does not fit.
class _ThumbnailStrip extends StatelessWidget {
  final List<String> images;
  final int totalCount;
  final int maxVisible;

  static const double _size = 30;

  /// How far each circle is tucked under the one before it.
  static const double _overlap = 10;

  const _ThumbnailStrip({required this.images, required this.totalCount, required this.maxVisible});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    /// A bundle with no thumbnail of its own still gets one circle, so the row
    /// reads as "no picture" rather than as the strip having failed to render.
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
