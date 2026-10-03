import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/item_shimmer_widget.dart';
import 'package:sixam_mart_store/features/service_module/store/controllers/service_store_controller.dart';
import 'package:sixam_mart_store/features/service_module/store/widgets/service_widget.dart';
import 'package:sixam_mart_store/util/dimensions.dart';

class ServiceViewWidget extends StatefulWidget {
  final ScrollController scrollController;
  final String? search;
  final String status;
  final int? categoryId;
  const ServiceViewWidget({super.key, required this.scrollController, this.search, this.status = 'all', this.categoryId});

  @override
  State<ServiceViewWidget> createState() => _ServiceViewWidgetState();
}

class _ServiceViewWidgetState extends State<ServiceViewWidget> {
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
    final controller = Get.find<ServiceStoreController>();

    if (widget.scrollController.position.pixels == widget.scrollController.position.maxScrollExtent
        && controller.serviceList != null
        && !controller.isLoading) {
      final int pageSize = ((controller.serviceSize ?? 0) / 10).ceil();
      if (controller.serviceOffset <= pageSize) {
        controller.showBottomLoader();
        controller.getServiceList(
          offset: controller.serviceOffset.toString(),
          status: widget.status,
          search: widget.search ?? '',
          categoryId: widget.categoryId,
        );
      }
    }

    if (widget.scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      controller.setFabVisible(false);
    } else if (widget.scrollController.position.userScrollDirection == ScrollDirection.forward) {
      controller.setFabVisible(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceStoreController>(builder: (controller) {
      return Column(children: [
        controller.serviceList != null
            ? controller.serviceList!.isNotEmpty
                ? GridView.builder(
                    key: UniqueKey(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: Dimensions.paddingSizeLarge,
                      mainAxisSpacing: 0.01,
                      crossAxisCount: 1,
                      mainAxisExtent: 104,
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: controller.serviceList!.length,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                        child: ServiceWidget(
                          service: controller.serviceList![index],
                          index: index,
                          length: controller.serviceList!.length,
                        ),
                      );
                    },
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 200),
                    child: Center(child: Text('no_service_available'.tr)),
                  )
            : GridView.builder(
                key: UniqueKey(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: Dimensions.paddingSizeLarge,
                  mainAxisSpacing: 0.01,
                  crossAxisCount: 1,
                  mainAxisExtent: 120,
                ),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 20,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                itemBuilder: (context, index) {
                  return ItemShimmerWidget(
                    isEnabled: controller.serviceList == null,
                    hasDivider: index != 19,
                  );
                },
              ),

        controller.isLoading
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  ),
                ),
              )
            : const SizedBox(),
      ]);
    });
  }
}
