import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:sixam_mart_store/features/order/domain/models/order_details_model.dart';
import 'package:sixam_mart_store/features/order_edit/widgets/quantity_button_widget.dart';
import 'package:sixam_mart_store/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_store/features/store/domain/models/item_model.dart';
import 'package:sixam_mart_store/helper/price_converter_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';

class BogoVariationSummaryLine {
  final String groupName;
  final String selectedLabels;
  const BogoVariationSummaryLine({required this.groupName, required this.selectedLabels});
}

class BogoSelectedItemResult {
  final Item item;
  final List<BogoVariationSummaryLine> variationSummaries;
  final int quantity;

  final List<OrderVariation> variations;
  final List<int> variationOptionIds;
  final List<AddOn> addOns;

  final double unitPrice;
  const BogoSelectedItemResult({
    required this.item, this.variationSummaries = const [], required this.quantity,
    this.variations = const [], this.variationOptionIds = const [], this.addOns = const [],
    this.unitPrice = 0,
  });
}

class BogoItemDetailsBottomSheet extends StatefulWidget {
  final Item item;
  final bool ignoreDiscount;
  const BogoItemDetailsBottomSheet({super.key, required this.item, this.ignoreDiscount = false});

  @override
  State<BogoItemDetailsBottomSheet> createState() => _BogoItemDetailsBottomSheetState();
}

class _BogoItemDetailsBottomSheetState extends State<BogoItemDetailsBottomSheet> {
  late final Item _item;

  final int _quantity = 1;

  final Map<int, Set<int>> _selectedOptions = {};

  late final List<FoodVariation> _foodVariations;
  late final List<Variation> _variations;
  late final List<ChoiceOptions> _choiceOptions;
  late List<int> _selectedChoiceIndex;
  int _selectedVariationIndex = 0;

  List<bool> _addOnActiveList = [];
  List<int> _addOnQtyList = [];

  bool get _isNewVariation => _foodVariations.isNotEmpty;

  /// How tall the sheet opens, as a fraction of the screen.
  ///
  /// An item with no description, no variations and no add-ons has a few lines
  /// to show, and opening at [_maxInitialSize] leaves most of the sheet empty.
  /// The content cannot be measured before it is laid out, so the sheet opens at
  /// the full size and [_measureSheet] shrinks it on the first frame — which
  /// resizes it rather than merely recording a number, because
  /// DraggableScrollableSheet moves to a new `initialChildSize` on rebuild for
  /// as long as the sheet has not been dragged.
  static const double _maxInitialSize = 0.85;
  static const double _maxMinSize = 0.5;

  double _sheetInitialSize = _maxInitialSize;
  double _sheetMinSize = _maxMinSize;
  double _sheetMaxSize = 1.0;
  bool _hasMeasured = false;

  final GlobalKey _headerKey = GlobalKey();
  final GlobalKey _contentKey = GlobalKey();
  final GlobalKey _footerKey = GlobalKey();

  /// The scroll view's own padding, which sits outside [_contentKey].
  static const double _contentPadding = Dimensions.paddingSizeDefault * 2;

  void _measureSheet() {
    if(_hasMeasured || !mounted) {
      return;
    }

    final double? header = _heightOf(_headerKey);
    final double? content = _heightOf(_contentKey);
    final double? footer = _heightOf(_footerKey);
    if(header == null || content == null || footer == null) {
      return;
    }

    final double screenHeight = MediaQuery.of(context).size.height;
    if(screenHeight <= 0) {
      return;
    }
    _hasMeasured = true;

    final double needed = (header + content + _contentPadding + footer) / screenHeight;

    final double initial = math.min(needed, _maxInitialSize);

    /// The ceiling is the content too, not the screen. Dragging a sheet up past
    /// what it has to show only opens a gap above the footer — there is nothing
    /// further to reveal, so there is nothing to drag towards.
    final double max = math.min(needed, 1.0);

    /// Kept below the opening size so dragging down still dismisses the sheet,
    /// the way it does at the full height.
    final double min = math.min(_maxMinSize, initial * 0.8);

    if(initial == _sheetInitialSize && max == _sheetMaxSize && min == _sheetMinSize) {
      return;
    }

    setState(() {
      _sheetInitialSize = initial;
      _sheetMaxSize = max;
      _sheetMinSize = min;
    });
  }

  /// Null until the widget has been laid out.
  double? _heightOf(GlobalKey key) {
    final RenderBox? box = key.currentContext?.findRenderObject() as RenderBox?;
    return box != null && box.hasSize ? box.size.height : null;
  }

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _foodVariations = _item.foodVariations ?? [];
    _variations = _item.variations ?? [];
    _choiceOptions = _item.choiceOptions ?? [];
    _selectedChoiceIndex = List<int>.filled(_choiceOptions.length, 0);
    _addOnActiveList = List.filled(_item.addOns?.length ?? 0, false);
    _addOnQtyList = List.filled(_item.addOns?.length ?? 0, 1);

    WidgetsBinding.instance.addPostFrameCallback((_) => _measureSheet());
  }

  Variation? get _matchedVariation {
    if(_variations.isEmpty) {
      return null;
    }
    if(_choiceOptions.isNotEmpty) {
      final List<String> selected = [];
      for(int i = 0; i < _choiceOptions.length; i++) {
        final List<String>? options = _choiceOptions[i].options;
        if(options != null && _selectedChoiceIndex[i] < options.length) {
          selected.add(options[_selectedChoiceIndex[i]].trim().replaceAll(' ', ''));
        }
      }
      final String type = selected.join('-');
      for(final Variation variation in _variations) {
        if(variation.type == type) {
          return variation;
        }
      }
      return null;
    }
    return _selectedVariationIndex < _variations.length ? _variations[_selectedVariationIndex] : null;
  }

  double get _variationPrice {
    if(!_isNewVariation) {
      return 0;
    }
    double total = 0;
    _selectedOptions.forEach((groupIndex, optionIndexes) {
      final List<VariationValue>? options = _foodVariations[groupIndex].variationValues;
      for(int optionIndex in optionIndexes) {
        if(options != null && options.length > optionIndex) {
          total += double.tryParse(options[optionIndex].optionPrice ?? '') ?? 0;
        }
      }
    });
    return total;
  }

  double get _addOnPrice {
    double total = 0;
    final List<AddOns> itemAddOns = _item.addOns ?? [];
    for(int index = 0; index < itemAddOns.length; index++) {
      if(index < _addOnActiveList.length && _addOnActiveList[index]) {
        total += (itemAddOns[index].price ?? 0) * _addOnQtyList[index];
      }
    }
    return total;
  }

  double get _unitPrice {
    final double basePrice = _item.price ?? 0;
    final double discounted = widget.ignoreDiscount ? basePrice
        : PriceConverterHelper.convertWithDiscount(basePrice, _item.discount ?? 0, _item.discountType) ?? basePrice;
    if(!_isNewVariation) {
      return _matchedVariation?.price ?? discounted;
    }
    return discounted;
  }

  void _toggleOption(int groupIndex, int optionIndex, bool isMultiSelect) {
    final Set<int> current = _selectedOptions.putIfAbsent(groupIndex, () => <int>{});
    final int max = _groupMax(groupIndex);

    if(isMultiSelect && !current.contains(optionIndex) && max > 0 && current.length >= max) {
      showCustomSnackBar('${'you_can_select_maximum'.tr} $max ${'options_from'.tr} ${_foodVariations[groupIndex].name}');
      return;
    }

    setState(() {
      if(isMultiSelect) {
        current.contains(optionIndex) ? current.remove(optionIndex) : current.add(optionIndex);
      } else {
        current..clear()..add(optionIndex);
      }
    });
  }

  bool _isRequired(String? required) {
    return required == 'on' || required == '1' || required == 'true' || required == 'yes';
  }

  int _groupMin(int groupIndex) => int.tryParse(_foodVariations[groupIndex].min ?? '') ?? 0;
  int _groupMax(int groupIndex) => int.tryParse(_foodVariations[groupIndex].max ?? '') ?? 0;

  void _toggleAddOn(int index) {
    setState(() => _addOnActiveList[index] = !_addOnActiveList[index]);
  }

  void _setAddOnQuantity(int index, bool isIncrement) {
    setState(() {
      if(isIncrement) {
        _addOnQtyList[index]++;
      } else if(_addOnQtyList[index] > 1) {
        _addOnQtyList[index]--;
      } else {
        _addOnActiveList[index] = false;
      }
    });
  }

  void _onAddPressed() {
    final List<BogoVariationSummaryLine> variationSummaries = [];
    final List<OrderVariation> orderVariations = [];
    final List<int> variationOptionIds = [];

    if(_isNewVariation) {
      for(int groupIndex = 0; groupIndex < _foodVariations.length; groupIndex++) {
        final FoodVariation group = _foodVariations[groupIndex];
        final bool isMultiSelect = group.type == 'multi';
        final bool isRequired = _isRequired(group.required);
        final int min = _groupMin(groupIndex);
        final int selectedCount = _selectedOptions[groupIndex]?.length ?? 0;

        if(!isMultiSelect && isRequired && selectedCount == 0) {
          showCustomSnackBar('${'choose_a_variation_from'.tr} ${group.name}');
          return;
        } else if(isMultiSelect && (isRequired || selectedCount > 0) && selectedCount < min) {
          showCustomSnackBar('${'you_need_to_select_minimum'.tr} $min ${'to_maximum'.tr} ${_groupMax(groupIndex)} ${'options_from'.tr} ${group.name} ${'variation'.tr}');
          return;
        }
      }

      for(int groupIndex = 0; groupIndex < _foodVariations.length; groupIndex++) {
        final Set<int>? optionIndexes = _selectedOptions[groupIndex];
        if(optionIndexes == null || optionIndexes.isEmpty) continue;

        final List<VariationValue>? options = _foodVariations[groupIndex].variationValues;
        final List<String> labels = [];
        for(int optionIndex in optionIndexes) {
          if(options == null || options.length <= optionIndex) continue;
          final VariationValue option = options[optionIndex];
          if(option.level != null && option.level!.trim().isNotEmpty) {
            labels.add(option.level!.trim());
          }
          final int? optionId = int.tryParse(option.optionId ?? '');
          if(optionId != null) {
            variationOptionIds.add(optionId);
          }
        }

        if(labels.isNotEmpty) {
          variationSummaries.add(BogoVariationSummaryLine(groupName: _foodVariations[groupIndex].name ?? '', selectedLabels: labels.join(', ')));
          orderVariations.add(OrderVariation(name: _foodVariations[groupIndex].name, values: OrderVariationValue(label: labels)));
        }
      }
    } else if(_variations.isNotEmpty) {
      final Variation? matched = _matchedVariation;
      if(matched == null) {
        showCustomSnackBar('please_select_required_variations'.tr);
        return;
      }

      orderVariations.add(OrderVariation(name: 'variation', values: OrderVariationValue(label: [matched.type ?? ''])));

      if(_choiceOptions.isNotEmpty) {
        for(int i = 0; i < _choiceOptions.length; i++) {
          final List<String>? options = _choiceOptions[i].options;
          if(options != null && _selectedChoiceIndex[i] < options.length) {
            variationSummaries.add(BogoVariationSummaryLine(
              groupName: _choiceOptions[i].title ?? '', selectedLabels: options[_selectedChoiceIndex[i]],
            ));
          }
        }
      } else {
        variationSummaries.add(BogoVariationSummaryLine(groupName: 'variation'.tr, selectedLabels: matched.type ?? ''));
      }
    }

    final List<AddOns> itemAddOns = _item.addOns ?? [];
    final List<AddOn> selectedAddOns = [];
    for(int index = 0; index < itemAddOns.length; index++) {
      if(index < _addOnActiveList.length && _addOnActiveList[index]) {
        selectedAddOns.add(AddOn(id: itemAddOns[index].id, quantity: _addOnQtyList[index]));
        variationSummaries.add(BogoVariationSummaryLine(
          groupName: 'addons'.tr, selectedLabels: '${itemAddOns[index].name ?? ''} x${_addOnQtyList[index]}',
        ));
      }
    }

    Navigator.pop(context, BogoSelectedItemResult(
      item: _item, quantity: _quantity, variationSummaries: variationSummaries,
      variations: orderVariations, variationOptionIds: variationOptionIds, addOns: selectedAddOns,
      unitPrice: _unitPrice + _variationPrice + _addOnPrice,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double totalPrice = (_unitPrice + _variationPrice + _addOnPrice) * _quantity;

    return DraggableScrollableSheet(
      initialChildSize: _sheetInitialSize,
      minChildSize: _sheetMinSize,
      maxChildSize: _sheetMaxSize,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
          ),
          child: Column(children: [

            KeyedSubtree(
              key: _headerKey,
              child: _StickyHeader(scrollController: scrollController, theme: theme, itemName: _item.name ?? ''),
            ),

            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                /// Without this the sheet cannot be dragged open once the content
                /// fits. The default physics refuse a drag when there is nothing
                /// to scroll (`minScrollExtent == maxScrollExtent` and
                /// `pixels == 0`), so it never reaches the sheet's
                /// `applyUserOffset` — which is the very place that decides
                /// between moving the sheet and scrolling the content. Accepting
                /// the drag unconditionally hands that decision back: the sheet
                /// rises while the content sits at the top, and the content
                /// scrolls once there is an overflow to scroll through.
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(key: _contentKey, crossAxisAlignment: CrossAxisAlignment.start, children: [

                  _buildHeader(theme),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  if(_item.description != null && _item.description!.isNotEmpty) ...[
                    Text('description'.tr, style: robotoSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Text(_item.description!, style: robotoRegular.copyWith(color: theme.hintColor)),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                  ],

                  if(_item.nutrition != null && _item.nutrition!.isNotEmpty) ...[
                    Text('nutrition_details'.tr, style: robotoSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Text(_item.nutrition!.whereType<String>().join(', '), style: robotoRegular.copyWith(color: theme.hintColor)),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                  ],

                  if(_item.allergies != null && _item.allergies!.isNotEmpty) ...[
                    Text('allergic_ingredients'.tr, style: robotoSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Text(_item.allergies!.whereType<String>().join(', '), style: robotoRegular.copyWith(color: theme.hintColor)),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                  ],

                  if(_isNewVariation)
                    ...List.generate(_foodVariations.length, (groupIndex) => _FoodVariationGroupWidget(
                      theme: theme, variation: _foodVariations[groupIndex], groupIndex: groupIndex,
                      selectedOptionIndexes: _selectedOptions[groupIndex] ?? const <int>{},
                      onToggleOption: _toggleOption,
                    ))
                  else
                    ..._buildLegacyVariations(theme),

                  if(_item.addOns != null && _item.addOns!.isNotEmpty)
                    _AddOnListWidget(
                      theme: theme, addOns: _item.addOns!,
                      activeList: _addOnActiveList, qtyList: _addOnQtyList,
                      onToggle: _toggleAddOn, onSetQuantity: _setAddOnQuantity,
                    ),

                ]),
              ),
            ),

            Container(
              key: _footerKey,
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [BoxShadow(color: theme.shadowColor, spreadRadius: 0, blurRadius: 5)],
              ),
              child: SafeArea(
                top: false,
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('total'.tr, style: robotoMedium),
                    Text(
                      PriceConverterHelper.convertPrice(totalPrice), textDirection: TextDirection.ltr,
                      style: robotoMedium,
                    ),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  CustomButtonWidget(buttonText: 'add_this_item'.tr, onPressed: _onAddPressed),
                ]),
              ),
            ),

          ]),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final double basePrice = _item.price ?? 0;
    final double discount = widget.ignoreDiscount ? 0 : _item.discount ?? 0;
    final double priceWithDiscount = PriceConverterHelper.convertWithDiscount(basePrice, discount, _item.discountType) ?? basePrice;
    final bool showVegBadge = (Get.find<SplashController>().configModel?.toggleVegNonVeg ?? false)
        && (Get.find<SplashController>().configModel?.moduleConfig?.module?.vegNonVeg ?? false);

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        child: CustomImageWidget(image: _item.imageFullUrl ?? '', height: 80, width: 80, fit: BoxFit.cover),
      ),
      const SizedBox(width: Dimensions.paddingSizeSmall),

      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          _item.name ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
          style: robotoSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
        ),
        _RatingWidget(rating: _item.avgRating ?? 0, ratingCount: _item.ratingCount ?? 0),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Row(children: [
          Expanded(
            child: Row(children: [
              discount > 0 ? Text(
                PriceConverterHelper.convertPrice(basePrice), textDirection: TextDirection.ltr,
                style: robotoRegular.copyWith(color: theme.hintColor, decoration: TextDecoration.lineThrough, fontSize: Dimensions.fontSizeSmall),
              ) : const SizedBox(),
              SizedBox(width: discount > 0 ? Dimensions.paddingSizeExtraSmall : 0),

              Text(
                PriceConverterHelper.convertPrice(priceWithDiscount), textDirection: TextDirection.ltr,
                style: robotoSemiBold.copyWith(color: theme.primaryColor),
              ),
            ]),
          ),
          SizedBox(width: Dimensions.paddingSizeSmall),

          showVegBadge ? Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
            decoration: BoxDecoration(
              border: Border.all(color: theme.disabledColor.withAlpha(80), width: 1.5),
              borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.end, children: [
              Image.asset(_item.veg == 1 ? Images.vegIcon : Images.nonVegIcon, height: 18, width: 18),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Text(_item.veg == 1 ? 'veg'.tr : 'non_veg'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
            ]),
          ) : const SizedBox(),
        ]),
      ])),
    ]);
  }

  List<Widget> _buildLegacyVariations(ThemeData theme) {
    final List<Widget> widgets = [];

    if(_choiceOptions.isNotEmpty) {
      for(int i = 0; i < _choiceOptions.length; i++) {
        final ChoiceOptions choice = _choiceOptions[i];
        widgets.add(_legacyHeader(theme, choice.title ?? ''));
        for(int j = 0; j < (choice.options?.length ?? 0); j++) {
          widgets.add(_legacyRow(
            theme,
            selected: _selectedChoiceIndex[i] == j,
            title: choice.options![j],
            price: null,
            onTap: () => setState(() => _selectedChoiceIndex[i] = j),
          ));
        }
      }
    } else if(_variations.isNotEmpty) {
      widgets.add(_legacyHeader(theme, 'variations'.tr));
      for(int i = 0; i < _variations.length; i++) {
        widgets.add(_legacyRow(
          theme,
          selected: _selectedVariationIndex == i,
          title: _variations[i].type ?? '',
          price: _variations[i].price,
          onTap: () => setState(() => _selectedVariationIndex = i),
        ));
      }
    }

    if(widgets.isNotEmpty) {
      widgets.add(const SizedBox(height: Dimensions.paddingSizeDefault));
    }
    return widgets;
  }

  Widget _legacyHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeExtraSmall),
      child: Text(title, style: robotoSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge), maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }

  Widget _legacyRow(ThemeData theme, {required bool selected, required String title, double? price, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
        child: Row(children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: 18, color: selected ? theme.primaryColor : theme.hintColor,
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(
            child: Text(
              title, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: theme.hintColor),
            ),
          ),

          price != null ? Text(
            PriceConverterHelper.convertPrice(price), textDirection: TextDirection.ltr,
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: theme.hintColor),
          ) : const SizedBox(),
        ]),
      ),
    );
  }
}

class _StickyHeader extends StatefulWidget {
  final ScrollController scrollController;
  final ThemeData theme;
  final String itemName;
  const _StickyHeader({required this.scrollController, required this.theme, required this.itemName});

  @override
  State<_StickyHeader> createState() => _StickyHeaderState();
}

class _StickyHeaderState extends State<_StickyHeader> {
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final bool shouldShow = widget.scrollController.hasClients && widget.scrollController.offset > 10;
    if(shouldShow != _showTitle) {
      setState(() => _showTitle = shouldShow);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = widget.theme;

    return Padding(
      padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeSmall),
      child: Row(children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _showTitle ? Align(
              key: const ValueKey('title'),
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                child: Text(
                  widget.itemName, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: robotoSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
              ),
            ) : Align(
              key: const ValueKey('handle'),
              alignment: Alignment.center,
              child: Container(
                height: 4, width: 40,
                decoration: BoxDecoration(color: theme.disabledColor.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
              ),
            ),
          ),
        ),

        InkWell(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: _showTitle ? const EdgeInsets.only(top: Dimensions.paddingSizeLarge) : EdgeInsets.zero,
            child: Icon(Icons.close, size: 22, color: theme.hintColor),
          ),
        ),
      ]),
    );
  }
}

class _FoodVariationGroupWidget extends StatelessWidget {
  final ThemeData theme;
  final FoodVariation variation;
  final int groupIndex;
  final Set<int> selectedOptionIndexes;
  final void Function(int groupIndex, int optionIndex, bool isMultiSelect) onToggleOption;

  const _FoodVariationGroupWidget({
    required this.theme, required this.variation, required this.groupIndex,
    required this.selectedOptionIndexes, required this.onToggleOption,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRequired = variation.required == 'on' || variation.required == '1' || variation.required == 'true' || variation.required == 'yes';
    final bool isMultiSelect = variation.type == 'multi';
    final List<VariationValue> options = variation.variationValues ?? [];
    final int min = int.tryParse(variation.min ?? '') ?? 0;
    final int max = int.tryParse(variation.max ?? '') ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(variation.name ?? '', style: robotoSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),

          if(isRequired)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              child: Text('required'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: theme.colorScheme.error)),
            ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Text(
          isMultiSelect ? '${'select_minimum'.tr} $min ${'and_up_to'.tr} $max ${'options'.tr}' : 'select_one'.tr,
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: theme.hintColor),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        ...List.generate(options.length, (optionIndex) {
          final VariationValue option = options[optionIndex];
          final bool isSelected = selectedOptionIndexes.contains(optionIndex);
          final double optionPrice = double.tryParse(option.optionPrice ?? '') ?? 0;

          return InkWell(
            onTap: () => onToggleOption(groupIndex, optionIndex, isMultiSelect),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
              child: Row(children: [
                Icon(
                  isMultiSelect
                      ? (isSelected ? Icons.check_box : Icons.check_box_outline_blank)
                      : (isSelected ? Icons.radio_button_checked : Icons.radio_button_off),
                  size: 18, color: isSelected ? theme.primaryColor : theme.hintColor,
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  child: Text(
                    option.level?.trim() ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: theme.hintColor),
                  ),
                ),

                Text(
                  PriceConverterHelper.convertPrice(optionPrice), textDirection: TextDirection.ltr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: theme.hintColor),
                ),
              ]),
            ),
          );
        }),
      ]),
    );
  }
}

class _AddOnListWidget extends StatelessWidget {
  final ThemeData theme;
  final List<AddOns> addOns;
  final List<bool> activeList;
  final List<int> qtyList;
  final void Function(int index) onToggle;
  final void Function(int index, bool isIncrement) onSetQuantity;

  const _AddOnListWidget({
    required this.theme, required this.addOns, required this.activeList, required this.qtyList,
    required this.onToggle, required this.onSetQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('addons'.tr, style: robotoSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        ...List.generate(addOns.length, (index) {
          final AddOns addOn = addOns[index];
          final bool isActive = index < activeList.length && activeList[index];
          final int qty = index < qtyList.length ? qtyList[index] : 1;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
            child: Row(children: [
              Checkbox(
                value: isActive,
                activeColor: theme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                onChanged: (_) => onToggle(index),
                visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                side: BorderSide(width: 2, color: theme.hintColor),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Expanded(
                child: Text(
                  addOn.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: isActive ? robotoMedium : robotoRegular.copyWith(color: theme.hintColor),
                ),
              ),

              Text(
                (addOn.price ?? 0) > 0 ? PriceConverterHelper.convertPrice(addOn.price) : 'free'.tr,
                textDirection: TextDirection.ltr,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: theme.hintColor),
              ),

              if(isActive) ...[
                const SizedBox(width: Dimensions.paddingSizeSmall),
                QuantityButton(isIncrement: false, onTap: () => onSetQuantity(index, false)),
                Text('$qty', style: robotoMedium),
                QuantityButton(isIncrement: true, onTap: () => onSetQuantity(index, true)),
              ],
            ]),
          );
        }),
      ]),
    );
  }
}

class _RatingWidget extends StatelessWidget {
  final double rating;
  final int ratingCount;
  const _RatingWidget({required this.rating, required this.ratingCount});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.star_rounded, color: theme.primaryColor, size: 16),
      const SizedBox(width: 2),

      Text(rating.toStringAsFixed(1), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
      const SizedBox(width: 2),

      Text('($ratingCount+)', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: theme.hintColor)),
    ]);
  }
}
