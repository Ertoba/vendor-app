import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/features/service_module/booking_edit/controllers/booking_edit_controller.dart';
import 'package:sixam_mart_store/features/service_module/booking_edit/domain/models/booking_edit_catalog_model.dart';
import 'package:sixam_mart_store/features/service_module/booking_edit/domain/models/booking_edit_working_line_model.dart';
import 'package:sixam_mart_store/helper/price_converter_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';

/// Variant + quantity picker shown when adding a service that has variants, or
/// when editing an existing booking line for such a service. Simpler than the
/// order-edit item-details sheet since a booking service has a single flat
/// variant dimension (no add-ons, no multi-group food-variations).
class BookingServiceVariantBottomSheetWidget extends StatefulWidget {
  final BookingEditCatalogService service;
  final BookingEditWorkingLine? workingLine;
  final int? editIndex;
  const BookingServiceVariantBottomSheetWidget({super.key, required this.service, this.workingLine, this.editIndex});

  @override
  State<BookingServiceVariantBottomSheetWidget> createState() => _BookingServiceVariantBottomSheetWidgetState();
}

class _BookingServiceVariantBottomSheetWidgetState extends State<BookingServiceVariantBottomSheetWidget> {
  int? _selectedVariantIndex;
  int _quantity = 1;
  int _matchedIndex = -1;

  bool get _isEditMode => widget.editIndex != null;
  bool get _showUpdate => _isEditMode || _matchedIndex != -1;

  @override
  void initState() {
    super.initState();
    final List<BookingEditCatalogVariant> variants = widget.service.variants ?? [];

    if (widget.workingLine != null) {
      _quantity = widget.workingLine!.quantity;
      if (variants.isNotEmpty) {
        final int idx = variants.indexWhere((v) => v.key == widget.workingLine!.variantKey);
        _selectedVariantIndex = idx >= 0 ? idx : null;
      }
    } else if (variants.length == 1) {
      _selectedVariantIndex = 0;
    }

    if (!_isEditMode) _updateMatch();
  }

  void _updateMatch() {
    final BookingEditController controller = Get.find<BookingEditController>();
    final List<BookingEditCatalogVariant> variants = widget.service.variants ?? [];
    final String? selectedKey = _selectedVariantIndex != null && _selectedVariantIndex! < variants.length ? variants[_selectedVariantIndex!].key : null;

    if (variants.isNotEmpty && selectedKey == null) {
      _matchedIndex = -1;
      return;
    }

    final int? found = controller.findMatchingLineIndex(widget.service.id ?? 0, selectedKey);
    if (found != _matchedIndex) {
      _matchedIndex = found ?? -1;
      if (found != null) {
        _quantity = controller.workingLines![found].quantity;
      } else {
        _quantity = 1;
      }
    }
  }

  BookingEditCatalogVariant? get _selectedVariant {
    final variants = widget.service.variants ?? [];
    if (_selectedVariantIndex == null || _selectedVariantIndex! >= variants.length) return null;
    return variants[_selectedVariantIndex!];
  }

  double get _unitPrice => _selectedVariant?.unitPrice ?? widget.service.unitPrice ?? 0;
  double get _totalPrice => _unitPrice * _quantity;

  @override
  Widget build(BuildContext context) {
    final List<BookingEditCatalogVariant> variants = widget.service.variants ?? [];

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
          child: Container(height: 4, width: 40, decoration: BoxDecoration(color: Theme.of(context).disabledColor.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10))),
        ),

        Flexible(child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          physics: const BouncingScrollPhysics(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text(widget.service.name ?? '', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text(PriceConverterHelper.convertPrice(_unitPrice), style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge)),

            if (variants.isNotEmpty) ...[
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Text('variations'.tr, style: robotoBold),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: variants.length,
                itemBuilder: (context, i) {
                  final BookingEditCatalogVariant variant = variants[i];
                  final bool selected = _selectedVariantIndex == i;
                  return InkWell(
                    onTap: () => setState(() { _selectedVariantIndex = i; _updateMatch(); }),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                      child: Row(children: [
                        Icon(
                          selected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: selected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, size: 22,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(child: Text(variant.name ?? '', style: selected ? robotoMedium : robotoRegular)),
                        Text(PriceConverterHelper.convertPrice(variant.unitPrice ?? 0), style: robotoRegular.copyWith(color: Theme.of(context).primaryColor)),
                      ]),
                    ),
                  );
                },
              ),
            ],
          ]),
        )),

        Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 300]!, blurRadius: 10)],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('total'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              Text(PriceConverterHelper.convertPrice(_totalPrice), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor)),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Row(children: [
              _quantityButton(context, Icons.remove, () {
                if (_quantity > 1) setState(() => _quantity--);
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: Text(_quantity.toString(), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ),
              _quantityButton(context, Icons.add, () => setState(() => _quantity++), filled: true),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(child: CustomButtonWidget(
                buttonText: _showUpdate ? 'update'.tr : 'add_to_cart'.tr, height: 45, width: 200,
                onPressed: _onSubmit,
              )),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _quantityButton(BuildContext context, IconData icon, VoidCallback onTap, {bool filled = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 30, width: 30, alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? Theme.of(context).primaryColor : Theme.of(context).hintColor.withValues(alpha: 0.15),
        ),
        child: Icon(icon, size: 18, color: filled ? Colors.white : Theme.of(context).textTheme.bodyLarge!.color),
      ),
    );
  }

  bool _validate() {
    if ((widget.service.variants ?? []).isNotEmpty && _selectedVariant == null) {
      showCustomSnackBar('please_select_required_variations'.tr);
      return false;
    }
    return true;
  }

  void _onSubmit() {
    if (!_validate()) return;
    final BookingEditController controller = Get.find<BookingEditController>();

    if (_isEditMode) {
      controller.updateWorkingLine(
        widget.editIndex!,
        variantKey: _selectedVariant?.key, variantName: _selectedVariant?.name,
        unitPrice: _unitPrice, grossPrice: _selectedVariant?.grossPrice ?? widget.service.grossPrice,
        discount: _selectedVariant?.discount ?? widget.service.discount, quantity: _quantity,
      );
      Get.back();
      showCustomSnackBar('service_updated'.tr, isError: false);
    } else if (_matchedIndex != -1) {
      controller.updateWorkingLine(
        _matchedIndex,
        variantKey: _selectedVariant?.key, variantName: _selectedVariant?.name,
        unitPrice: _unitPrice, grossPrice: _selectedVariant?.grossPrice ?? widget.service.grossPrice,
        discount: _selectedVariant?.discount ?? widget.service.discount, quantity: _quantity,
      );
      Get.back();
      Get.back();
      showCustomSnackBar('service_updated'.tr, isError: false);
    } else {
      controller.addCatalogEntry(widget.service, variant: _selectedVariant, quantity: _quantity);
      Get.back();
      Get.back();
      showCustomSnackBar('service_added_to_booking'.tr, isError: false);
    }
  }
}
