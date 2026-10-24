import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/confirmation_dialog_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_store/common/widgets/discount_tag_widget.dart';
import 'package:sixam_mart_store/features/service_module/store/controllers/service_store_controller.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/models/service_list_model.dart';
import 'package:sixam_mart_store/helper/price_converter_helper.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';

class ServiceWidget extends StatelessWidget {
  final Service service;
  final int index;
  final int length;
  final bool showMenu;
  const ServiceWidget({super.key, required this.service, required this.index, required this.length, this.showMenu = true});

  @override
  Widget build(BuildContext context) {
    final double discount = service.discount ?? 0;
    final String discountType = service.discountType ?? 'percent';
    final double width = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: () => Get.toNamed(RouteHelper.getServiceDetailsRoute(service.id!)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(offset: const Offset(0, 3), color: Colors.grey[Get.isDarkMode ? 700 : 200]!, blurRadius: 8, spreadRadius: 0)],
        ),
        child: Row(children: [

          /// Thumbnail
          Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: CustomImageWidget(
                image: service.thumbnailFullUrl ?? '',
                height: 60, width: 69, fit: BoxFit.cover,
              ),
            ),
            DiscountTagWidget(discount: discount, discountType: discountType, freeDelivery: false),
          ]),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          /// Details
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text(
                service.name ?? '',
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              /// Rating
              if ((service.avgRating ?? 0) > 0)
                Row(children: [
                  Image.asset(Images.starIcon, width: 10),
                  Text(' ${service.avgRating!.toStringAsFixed(2)} ',
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                  Text('(${service.ratingCount})',
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Theme.of(context).hintColor,
                      decoration: TextDecoration.underline,
                      decorationColor: Theme.of(context).hintColor,
                    )),
                ]),
              const SizedBox(height: 2),

              /// Price
              Row(children: [
                if (discount > 0)
                  Text(
                    PriceConverterHelper.convertPrice(service.basePrice),
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Theme.of(context).disabledColor,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                if (discount > 0) const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Text(
                  PriceConverterHelper.convertPrice(service.basePrice, discount: discount, discountType: discountType),
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),
            ]),
          ),

          /// Actions
          if (showMenu) width > 320
              ? Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    onSelected: (String result) {
                      if (result == 'edit') {
                      } else if (result == 'delete') {
                        Get.dialog(ConfirmationDialogWidget(
                          icon: Images.warning,
                          description: 'are_you_sure_want_to_delete_this_service'.tr,
                          onYesPressed: () => Get.find<ServiceStoreController>().deleteService(service.id),
                        ));
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: ListTile(
                          title: Text('edit'.tr, style: robotoMedium),
                          trailing: const Icon(Icons.edit, color: Colors.blue),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(
                          title: Text('delete'.tr, style: robotoMedium),
                          trailing: const Icon(Icons.delete_forever, color: Colors.red),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                    icon: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: const Icon(Icons.more_vert_sharp, size: 20),
                    ),
                  ),
                ])
              : Row(children: [

                  GestureDetector(
                    onTap: () {
                      Get.dialog(ConfirmationDialogWidget(
                        icon: Images.warning,
                        description: 'are_you_sure_want_to_delete_this_service'.tr,
                        onYesPressed: () => Get.find<ServiceStoreController>().deleteService(service.id),
                      ));
                    },
                    child: const Icon(Icons.delete_forever, color: Colors.red),
                  ),
                ]),
        ]),
      ),
    );
  }
}
