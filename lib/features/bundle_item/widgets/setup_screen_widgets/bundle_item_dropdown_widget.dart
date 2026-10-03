part of '../../screens/create_bundle_package_screen.dart';

/// The searchable item list that drops out of the "Select Bundle Item" field.
class _BundleItemDropdownOverlay extends StatelessWidget {
  final ThemeData theme;
  final LayerLink layerLink;
  final double width;
  final bool showAbove;
  final double maxHeight;
  final BundleItemController bundleItemController;
  final TextEditingController searchController;
  final ScrollController scrollController;
  final String searchQuery;
  final Set<int> selectedIds;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onDismiss;
  final Future<void> Function(BuildContext context, BundleCatalogueItem row) onItemTap;

  const _BundleItemDropdownOverlay({
    required this.theme, required this.layerLink, required this.width, required this.showAbove, required this.maxHeight,
    required this.bundleItemController, required this.searchController, required this.scrollController, required this.searchQuery,
    required this.selectedIds, required this.onSearchChanged, required this.onDismiss, required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<BundleCatalogueItem>? itemList = bundleItemController.bundleItems;
    final List<BundleCatalogueItem> filteredItems = itemList == null ? [] : searchQuery.isEmpty
        ? itemList
        : itemList.where((row) => (row.item.name ?? '').toLowerCase().contains(searchQuery)).toList();

    return Stack(children: [

      Positioned.fill(child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onDismiss,
      )),

      CompositedTransformFollower(
        link: layerLink,
        showWhenUnlinked: false,
        targetAnchor: showAbove ? Alignment.topLeft : Alignment.bottomLeft,
        followerAnchor: showAbove ? Alignment.bottomLeft : Alignment.topLeft,
        offset: Offset(0, showAbove ? -4 : 4),
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: theme.cardColor,
          child: Container(
            width: width,
            constraints: BoxConstraints(maxHeight: maxHeight),
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Column(mainAxisSize: MainAxisSize.min, children: [

              TextField(
                controller: searchController,
                autofocus: false,
                onChanged: onSearchChanged,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                decoration: InputDecoration(
                  hintText: 'search_by_item_name'.tr,
                  hintStyle: robotoRegular.copyWith(color: theme.hintColor),
                  prefixIcon: Icon(Icons.search, color: theme.hintColor, size: 20),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge * 2),
                    borderSide: BorderSide(color: theme.disabledColor.withValues(alpha: 0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge * 2),
                    borderSide: BorderSide(color: theme.disabledColor.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge * 2),
                    borderSide: BorderSide(color: theme.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Flexible(
                child: itemList == null ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                  child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                ) : filteredItems.isEmpty ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                  child: Text('no_item_found'.tr, style: robotoRegular.copyWith(color: theme.hintColor)),
                ) : ListView.separated(
                  padding: EdgeInsets.zero,
                  controller: scrollController,
                  itemCount: filteredItems.length,
                  separatorBuilder: (context, index) => const SizedBox(height: Dimensions.paddingSizeSmall),
                  itemBuilder: (context, index) {
                    final BundleCatalogueItem row = filteredItems[index];
                    final Item item = row.item;
                    /// Already in the bundle doesn't block re-selection — the same item can be
                    /// added again with a different size or add-ons. Identical combinations are
                    /// merged after the picker, not blocked here.
                    final bool isAlreadyAdded = item.id != null && selectedIds.contains(item.id);
                    /// The endpoint returns unavailable items rather than hiding them, so that a
                    /// vendor who cannot find one can tell it is ineligible rather than missing.
                    final bool isAvailable = row.isAvailable;

                    return Opacity(
                      opacity: isAvailable ? 1 : 0.5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          border: Border.all(color: theme.disabledColor.withValues(alpha: 0.2), width: 1),
                        ),
                        child: ListTile(
                          dense: true,
                          enabled: isAvailable,
                          contentPadding: EdgeInsets.zero,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            child: CustomImageWidget(image: item.imageFullUrl ?? '', height: 40, width: 40, fit: BoxFit.cover),
                          ),
                          title: Text(
                            item.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: robotoSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                          ),
                          subtitle: Text(
                            isAvailable ? (item.storeCategoryName ?? '') : 'currently_unavailable'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: isAvailable ? theme.hintColor : theme.colorScheme.error,
                            ),
                          ),
                          trailing: isAlreadyAdded ? Icon(Icons.check_circle_outline, color: theme.primaryColor, size: 18) : null,
                          onTap: isAvailable ? () => onItemTap(context, row) : null,
                        ),
                      ),
                    );
                  },
                ),
              ),

            ]),
          ),
        ),
      ),

    ]);
  }
}
