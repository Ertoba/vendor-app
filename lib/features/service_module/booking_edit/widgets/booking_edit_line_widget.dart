import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/confirmation_dialog_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/features/order_edit/widgets/quantity_button_widget.dart';
import 'package:sixam_mart_store/features/service_module/booking_edit/controllers/booking_edit_controller.dart';
import 'package:sixam_mart_store/features/service_module/booking_edit/domain/models/booking_edit_catalog_model.dart';
import 'package:sixam_mart_store/features/service_module/booking_edit/domain/models/booking_edit_working_line_model.dart';
import 'package:sixam_mart_store/features/service_module/booking_edit/widgets/booking_service_variant_bottom_sheet_widget.dart';
import 'package:sixam_mart_store/helper/price_converter_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';

class BookingEditLineWidget extends StatelessWidget {
  final BookingEditWorkingLine line;
  final int index;
  const BookingEditLineWidget({super.key, required this.line, required this.index});

  @override
  Widget build(BuildContext context) {
    final BookingEditController controller = Get.find<BookingEditController>();

    return InkWell(
      onTap: line.missing ? null : () => _openVariantSheet(controller),
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [BoxShadow(offset: const Offset(0, 3), color: Colors.grey[Get.isDarkMode ? 700 : 200]!, blurRadius: 8)],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: CustomImageWidget(image: line.imageFullUrl ?? '', height: 44, width: 44, fit: BoxFit.cover),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text(line.serviceName ?? '', style: robotoMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
            if ((line.variantName ?? '').isNotEmpty) Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '${'variations'.tr}: ${line.variantName}',
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Row(children: [
              Expanded(child: Text(
                PriceConverterHelper.convertPrice(line.unitPrice * line.quantity),
                style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
              )),

              if (line.missing) Row(mainAxisSize: MainAxisSize.min, children: [
                Padding(
                  padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                  child: Text('service_no_longer_available'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).colorScheme.error)),
                ),
                QuantityButton(isIncrement: false, showRemoveIcon: true, onTap: () => _remove(controller)),
              ]) else Row(mainAxisSize: MainAxisSize.min, children: [
                QuantityButton(
                  isIncrement: false, size: 22,
                  showRemoveIcon: line.quantity == 1,
                  onTap: () {
                    if (line.quantity > 1) {
                      controller.decreaseLine(index);
                    } else {
                      _remove(controller);
                    }
                  },
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(line.quantity.toString(), style: robotoMedium),
                ),
                QuantityButton(isIncrement: true, size: 22, onTap: () => controller.increaseLine(index)),
              ]),
            ]),
          ])),
        ]),
      ),
    );
  }

  void _remove(BookingEditController controller) {
    Get.dialog(ConfirmationDialogWidget(
      icon: Images.deleteDialogIcon,
      title: 'are_you_sure_to_delete_this_service'.tr,
      description: 'if_once_you_delete_this_item_this_will_remove_from_item_list'.tr,
      onYesPressed: () {
        Get.back();
        if (!controller.removeLine(index)) {
          showCustomSnackBar('booking_must_contain_at_least_one_service'.tr);
        }
      },
    ));
  }

  void _openVariantSheet(BookingEditController controller) {
    final BookingEditCatalogService? service = (controller.catalog ?? []).firstWhereOrNull((s) => s.id == line.serviceId);
    if (service == null) return;
    Get.bottomSheet(
      BookingServiceVariantBottomSheetWidget(service: service, workingLine: line, editIndex: index),
      isScrollControlled: true, backgroundColor: Colors.transparent,
    );
  }
}
