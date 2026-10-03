part of '../../screens/create_bundle_package_screen.dart';

/// One line of the bundle under construction: the item, the combination it was
/// picked with, its price, and a remove action.
///
/// Quantity is fixed at 1 — a bundle line is always one copy of the item, so
/// there is no stepper to edit it.
class _SelectedBundleItemCard extends StatelessWidget {
  final BundleSelectedItem selectedItem;
  final VoidCallback onRemove;

  const _SelectedBundleItemCard({required this.selectedItem, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Item item = selectedItem.item;

    final String addOnSummary = selectedItem.addOnSummary;
    final List<String> subtitleParts = [
      if((item.storeCategoryName ?? '').isNotEmpty) item.storeCategoryName!,
      if(selectedItem.variationSummary.isNotEmpty) selectedItem.variationSummary,
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: CustomImageWidget(image: item.imageFullUrl ?? '', height: 40, width: 40, fit: BoxFit.cover),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text(
              item.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
            ),

            if(subtitleParts.isNotEmpty)
              Text(
                subtitleParts.join(' | '), maxLines: 1, overflow: TextOverflow.ellipsis,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: theme.hintColor),
              ),

            if(addOnSummary.isNotEmpty)
              Text(
                '${'add_on'.tr} : $addOnSummary',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: theme.hintColor),
              ),
          ])),

        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Row(children: [

          Expanded(child: Text(
            PriceConverterHelper.convertPrice(selectedItem.lineTotal),
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
          )),

          _RemoveButton(onTap: onRemove),

        ]),

    ]);
  }
}


class _RemoveButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RemoveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.error),
        ),
      ),
    );
  }
}
