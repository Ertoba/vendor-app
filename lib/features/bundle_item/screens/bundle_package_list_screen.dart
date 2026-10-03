import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/confirmation_dialog_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_popup_menu_button.dart';
import 'package:sixam_mart_store/features/bundle_item/controllers/bundle_item_controller.dart';
import 'package:sixam_mart_store/features/bundle_item/domain/models/bundle_item_model.dart';
import 'package:sixam_mart_store/helper/price_converter_helper.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';

part '../widgets/bundle_package_card_widget.dart';

/// Every bundle package the store has built, newest first.
class BundlePackageListScreen extends StatefulWidget {
  const BundlePackageListScreen({super.key});

  @override
  State<BundlePackageListScreen> createState() => _BundlePackageListScreenState();
}

class _BundlePackageListScreenState extends State<BundlePackageListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Get.find<BundleItemController>().getBundleList(offset: '1');
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final BundleItemController bundleItemController = Get.find<BundleItemController>();

    if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent
        && bundleItemController.bundleList != null && !bundleItemController.isLoading
        && !bundleItemController.hasReachedEnd) {
      bundleItemController.setOffset(bundleItemController.offset + 1);
      bundleItemController.showBottomLoader();
      bundleItemController.getBundleList(offset: bundleItemController.offset.toString());
    }
  }

  /// The controller reloads the list itself on a successful save, and the
  /// GetBuilder below picks that up — so this only has to open the form.
  void _openSetup({int? bundleId}) {
    Get.toNamed(RouteHelper.getCreateBundlePackageRoute(id: bundleId));
  }

  void _confirmDelete(BundlePackage bundle) {
    Get.dialog(ConfirmationDialogWidget(
      icon: Images.warning,
      title: 'delete_bundle_package'.tr,
      description: 'are_you_sure_to_delete_this_bundle_package'.tr,
      onYesPressed: () {
        Get.back();
        Get.find<BundleItemController>().deleteBundle(bundle.id!);
      },
    ), barrierDismissible: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'bundle_package_list'.tr),

      floatingActionButton: FloatingActionButton(
        heroTag: 'bundle_package_fab',
        onPressed: () => _openSetup(),
        tooltip: 'create_bundle_package'.tr,
        child: Icon(Icons.add),
      ),

      body: GetBuilder<BundleItemController>(builder: (bundleItemController) {
        final List<BundlePackage>? bundleList = bundleItemController.bundleList;

        if(bundleList == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if(bundleList.isEmpty) {
          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const CustomAssetImageWidget(Images.emptyBox, height: 60, width: 60),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text(
              'no_bundle_package_found'.tr,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).hintColor),
            ),
          ]));
        }

        return ListView.separated(
          controller: _scrollController,
          /// Extra room at the bottom so the floating button never covers the
          /// last card's actions menu.
          padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, 80),
          itemCount: bundleList.length + 1,
          separatorBuilder: (context, index) => const SizedBox(height: Dimensions.paddingSizeSmall),
          itemBuilder: (context, index) {
            if(index == bundleList.length) {
              return bundleItemController.isLoading ? const Center(child: Padding(
                padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: CircularProgressIndicator(),
              )) : const SizedBox();
            }

            final BundlePackage bundle = bundleList[index];
            return _BundlePackageCard(
              bundle: bundle,
              onTap: () => Get.toNamed(RouteHelper.getBundleItemDetailsRoute(id: bundle.id!)),
              onEdit: () => _openSetup(bundleId: bundle.id),
              onDelete: () => _confirmDelete(bundle),
            );
          },
        );
      }),
    );
  }
}
