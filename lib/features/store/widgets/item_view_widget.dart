import 'package:flutter/rendering.dart';
import 'package:sixam_mart_store/features/store/controllers/store_controller.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/common/widgets/item_shimmer_widget.dart';
import 'package:sixam_mart_store/common/widgets/item_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ItemViewWidget extends StatelessWidget {
  final ScrollController scrollController;
  final String? type;
  final Function(String type)? onVegFilterTap;
  final bool fromAllItems;
  final String? search;
  const ItemViewWidget({super.key, required this.scrollController, this.type, this.onVegFilterTap, this.fromAllItems = false, this.search});

  @override
  Widget build(BuildContext context) {
    Get.find<StoreController>().setOffset(1);
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent
          && Get.find<StoreController>().itemList != null
          && !Get.find<StoreController>().isLoading) {
        int pageSize = (Get.find<StoreController>().itemSize! / 10).ceil();
        if (Get.find<StoreController>().offset < pageSize) {
          Get.find<StoreController>().setOffset(Get.find<StoreController>().offset+1);
          debugPrint('end of the page');
          Get.find<StoreController>().showBottomLoader();
          Get.find<StoreController>().getItemList(
            offset: Get.find<StoreController>().offset.toString(), type: Get.find<StoreController>().type,
            search: search ?? '', categoryId: Get.find<StoreController>().categoryId,
          );
        }
      }
    });
    return GetBuilder<StoreController>(builder: (storeController) {
      return Column(children: [
        storeController.itemList != null ? storeController.itemList!.isNotEmpty ? GridView.builder(
          key: UniqueKey(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: 0.01,
            crossAxisCount: 1,
            mainAxisExtent: 104,
          ),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          /// The grid never scrolls on its own, so nothing needs hiding — and
          /// the default hard edge clip would otherwise cut every card's shadow
          /// off flush with the card.
          clipBehavior: Clip.none,
          itemCount: storeController.itemList!.length,
          /// Horizontal inset belongs to the screen around it; this only keeps
          /// the first and last card's shadow off the neighbouring sections.
          padding: EdgeInsets.only(top: fromAllItems ? 0 : Dimensions.paddingSizeSmall),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              child: ItemWidget(
                item: storeController.itemList![index],
                index: index, length: storeController.itemList!.length, isCampaign: false,
                inStore: true,
              ),
            );
          },
        ) : Padding(
          padding: const EdgeInsets.only(top: 200),
          child: Center(child: Text('no_item_available'.tr)),
        ) : GridView.builder(
          key: UniqueKey(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: 0.01,
            crossAxisCount: 1,
            mainAxisExtent: 120,
          ),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          clipBehavior: Clip.none,
          itemCount: 20,
          padding: EdgeInsets.only(top: fromAllItems ? 0 : Dimensions.paddingSizeSmall),
          itemBuilder: (context, index) {
            return ItemShimmerWidget(
              isEnabled: storeController.itemList == null, hasDivider: index != 19,
            );
          },
        ),

        storeController.isLoading ? Center(child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
        )) : const SizedBox(),

      ]);
    });
  }
}
