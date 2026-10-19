part of '../../screens/create_bundle_package_screen.dart';

/// The "Select Bundle Item*" dropdown plus the list of what has been picked.
///
/// The picked items live on [BundleItemController] rather than in this widget,
/// because the price fields two cards above are derived from them.
class _BundleItemSelectField extends StatefulWidget {
  final BundleItemController bundleItemController;
  const _BundleItemSelectField({required this.bundleItemController});

  @override
  State<_BundleItemSelectField> createState() => _BundleItemSelectFieldState();
}

class _BundleItemSelectFieldState extends State<_BundleItemSelectField> {
  final OverlayPortalController _overlayController = OverlayPortalController();
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _dropdownScrollController = ScrollController();
  String _searchQuery = '';

  @override
  void dispose() {
    _dropdownScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value.trim().toLowerCase());
  }

  void _toggleOverlay() {
    if(_overlayController.isShowing) {
      _overlayController.hide();
      return;
    }
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
    _overlayController.show();
  }

  Future<void> _openItemDetails(BuildContext context, BundleCatalogueItem row) async {
    final BogoSelectedItemResult? result = await showModalBottomSheet<BogoSelectedItemResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BogoItemDetailsBottomSheet(item: row.item, ignoreDiscount: true),
    );

    if(result == null) {
      return;
    }

    final List<BogoVariationSummaryLine> variationLines = result.variationSummaries
        .where((line) => line.groupName != 'addons'.tr).toList();

    /// A service's variants are surfaced through the sheet's legacy variation
    /// list, so what comes back is the variant's name — turn it into the
    /// `variant_key` the API wants.
    String? variantKey;
    if(row.isService) {
      for(final BogoVariationSummaryLine line in variationLines) {
        variantKey ??= row.variantNamed(line.selectedLabels)?.variantKey;
      }
      if(row.requiresVariant && variantKey == null) {
        showCustomSnackBar('please_select_a_variant'.tr);
        return;
      }
    }

    final List<AddOns> itemAddOns = result.item.addOns ?? const <AddOns>[];

    widget.bundleItemController.addSelectedItem(BundleSelectedItem(
      item: result.item,
      unitPrice: result.unitPrice,
      /// A bundle line is always one copy of the item — the picker sheet's own
      /// quantity stepper is for BOGO buy/free counts and does not apply here.
      quantity: 1,
      variationSummary: variationLines.map((line) => '${line.groupName}: ${line.selectedLabels}').join(', '),
      variations: result.variations.map((variation) => variation.toJson()).toList(),
      isService: row.isService,
      variantKey: variantKey,
      /// A service carries no add-ons, and the API does not accept them on a
      /// service line.
      addOnIds: row.isService ? const [] : result.addOns.map((addOn) => addOn.id).whereType<int>().toList(),
      addOnQtys: row.isService ? const [] : result.addOns.map((addOn) => addOn.quantity ?? 1).toList(),
      addOnNames: row.isService ? const [] : result.addOns.map((addOn) {
        final AddOns match = itemAddOns.firstWhere(
          (candidate) => candidate.id == addOn.id,
          orElse: () => AddOns(name: ''),
        );
        return match.name ?? '';
      }).toList(),
    ));

    _overlayController.hide();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<BundleSelectedItem> selectedItems = widget.bundleItemController.selectedItems;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      CompositedTransformTarget(
        link: _layerLink,
        child: OverlayPortal(
          controller: _overlayController,
          overlayChildBuilder: (overlayContext) {
            final RenderBox? fieldBox = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
            final double width = fieldBox?.size.width ?? 280;
            final double fieldHeight = fieldBox?.size.height ?? 0;
            final double fieldTop = fieldBox?.localToGlobal(Offset.zero).dy ?? 0;
            final double screenHeight = MediaQuery.of(context).size.height;

            const double preferredDropdownHeight = 280;
            final double spaceBelow = screenHeight - (fieldTop + fieldHeight);
            final double spaceAbove = fieldTop;
            final bool showAbove = spaceBelow < preferredDropdownHeight && spaceAbove > spaceBelow;
            final double maxDropdownHeight = (showAbove ? spaceAbove : spaceBelow) - Dimensions.paddingSizeDefault;

            return _BundleItemDropdownOverlay(
              theme: theme,
              layerLink: _layerLink,
              width: width,
              showAbove: showAbove,
              maxHeight: maxDropdownHeight.clamp(150, preferredDropdownHeight),
              bundleItemController: widget.bundleItemController,
              searchController: _searchController,
              scrollController: _dropdownScrollController,
              searchQuery: _searchQuery,
              selectedIds: selectedItems.map((selected) => selected.item.id).whereType<int>().toSet(),
              onSearchChanged: _onSearchChanged,
              onDismiss: _overlayController.hide,
              onItemTap: _openItemDetails,
            );
          },
          child: Container(
            key: _fieldKey,
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border.all(color: theme.disabledColor.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              onTap: _toggleOverlay,
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Row(children: [
                  Expanded(child: RichText(text: TextSpan(
                    text: 'select_bundle_item'.tr,
                    style: robotoRegular.copyWith(color: theme.hintColor),
                    children: [TextSpan(text: ' *', style: robotoRegular.copyWith(color: theme.colorScheme.error))],
                  ))),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Icon(Icons.arrow_drop_down, color: theme.hintColor),
                ]),
              ),
            ),
          ),
        ),
      ),

      /// The rows sit on the portion rather than each getting a surface of their
      /// own — a card per row would compete with the dropdown above them, which
      /// is the one object in this group the vendor acts on to add another.
      ...List.generate(selectedItems.length, (index) => Column(children: [

       index != 0 ? Divider(height: Dimensions.paddingSizeLarge, color: theme.disabledColor.withValues(alpha: 0.2), thickness: 1,) : SizedBox(height: Dimensions.paddingSizeLarge,),

        _SelectedBundleItemCard(
          selectedItem: selectedItems[index],
          onRemove: () => widget.bundleItemController.removeSelectedItem(index),
        ),
      ])),

    ]);
  }
}
