import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/confirmation_dialog_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_popup_menu_button.dart';
import 'package:sixam_mart_store/features/bundle_item/controllers/bundle_item_controller.dart';
import 'package:sixam_mart_store/features/bundle_item/domain/models/bundle_item_model.dart';
import 'package:sixam_mart_store/features/bundle_item/widgets/custom_switch_button.dart';
import 'package:sixam_mart_store/helper/price_converter_helper.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';

/// One bundle package, read-only apart from the activity switch that takes it
/// on and off the customer app.
class BundleItemDetailsScreen extends StatefulWidget {
  final int bundleId;
  const BundleItemDetailsScreen({super.key, required this.bundleId});

  @override
  State<BundleItemDetailsScreen> createState() => _BundleItemDetailsScreenState();
}

class _BundleItemDetailsScreenState extends State<BundleItemDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<BundleItemController>().getBundleDetails(widget.bundleId, isUpdate: false);
  }

  /// Bumped to rebuild the activity switch when a toggle does not land.
  int _statusResetCount = 0;

  Future<void> _toggleStatus(BundleItemController bundleItemController, int bundleId, bool value) async {
    if(bundleItemController.isStatusLoading) {
      setState(() => _statusResetCount++);
      return;
    }
    final bool isSuccess = await bundleItemController.changeBundleStatus(bundleId, value ? 1 : 0);
    if(!isSuccess && mounted) {
      setState(() => _statusResetCount++);
    }
  }

  /// Reopens this bundle in the setup form. A successful save writes the
  /// server's copy straight into the controller, so the refetch on return only
  /// covers the case where the vendor backed out mid-edit.
  Future<void> _openEdit() async {
    await Get.toNamed(RouteHelper.getCreateBundlePackageRoute(id: widget.bundleId));
    if(mounted) {
      Get.find<BundleItemController>().getBundleDetails(widget.bundleId, isUpdate: false);
    }
  }

  /// Same confirmation the list screen asks for, but this screen is showing the
  /// package being deleted — so it leaves once the delete lands.
  void _confirmDelete() {
    Get.dialog(ConfirmationDialogWidget(
      icon: Images.warning,
      title: 'delete_bundle_package'.tr,
      description: 'are_you_sure_to_delete_this_bundle_package'.tr,
      onYesPressed: () async {
        Get.back();
        final bool isSuccess = await Get.find<BundleItemController>().deleteBundle(widget.bundleId);
        if(isSuccess) {
          Get.back();
        }
      },
    ), barrierDismissible: false);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBarWidget(
        title: '${'bundle_item'.tr} #${widget.bundleId}',
        menuWidget: CustomPopupMenuButton(
          items: [
            MenuItem('edit'.tr, Icons.edit, 0, theme.primaryColor),
            MenuItem('delete'.tr, Icons.delete, 1, theme.colorScheme.error),
          ],
          onSelected: (value) => value == 0 ? _openEdit() : _confirmDelete(),
          child: Padding(
            padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
            child: Icon(Icons.more_vert, color: theme.hintColor),
          ),
        ),
      ),

      body: GetBuilder<BundleItemController>(builder: (bundleItemController) {
        final BundlePackage? bundle = bundleItemController.bundleDetails;

        if(bundle == null || bundle.id != widget.bundleId) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<BundleItem> items = bundle.items ?? const <BundleItem>[];

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            _Card(child: Row(children: [
              Expanded(child: Text('bundle_activity_status'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault))),
              CustomSwitchButton(
                /// The switch flips itself on tap, so a rejected or ignored toggle
                /// needs a fresh instance to fall back to the server's status.
                key: ValueKey('bundle_status_${bundle.status}_$_statusResetCount'),
                value: bundle.isActive,
                activeColor: theme.primaryColor,
                onChanged: (value) => _toggleStatus(bundleItemController, bundle.id!, value),
              ),
            ])),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            _Card(child: Column(children: [

              Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: CustomImageWidget(image: bundle.imageFullUrl ?? '', height: 60, width: 60, fit: BoxFit.cover),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    bundle.name ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Text(
                    '${'after_discount'.tr} : ${PriceConverterHelper.convertPrice(bundle.price)}',
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: theme.hintColor),
                  ),
                  if((bundle.visibilityStatus ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                      child: _VisibilityBadge(status: bundle.visibilityStatus!),
                    ),
                ])),
              ]),
              const Padding(padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault), child: Divider(height: 0)),

              _InfoRow(title: 'base_price'.tr, value: PriceConverterHelper.convertPrice(bundle.basePrice ?? 0)),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              _InfoRow(title: 'discount'.tr, value: '${_trimZeros(bundle.discountPercentage ?? 0)}%'),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              _InfoRow(title: 'validity'.tr, value: bundle.validity),

              if(bundle.isCreatedByAdmin) ...[
                const SizedBox(height: Dimensions.paddingSizeSmall),
                _InfoRow(title: 'created_by'.tr, value: 'admin'.tr),
              ],
            ])),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            if(items.isNotEmpty) _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Text('items'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              ...List.generate(items.length, (index) => Column(children: [
                _BundleItemRow(item: items[index]),

                /// Between rows only — a trailing rule would read as the start
                /// of another item that is not there.
                if(index != items.length - 1)
                  Divider(height: Dimensions.paddingSizeLarge, color: theme.disabledColor.withValues(alpha: 0.2), thickness: 1,),
              ])),
            ])),

          ]),
        );
      }),
    );
  }

  static String _trimZeros(double value) => value % 1 == 0 ? value.toInt().toString() : value.toString();
}

/// `visibility_status` folds the on/off switch and the schedule window into one
/// label — the API guide asks for it to be rendered, not recomputed.
class _VisibilityBadge extends StatelessWidget {
  final String status;
  const _VisibilityBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = switch(status) {
      'running' => Colors.green,
      'scheduled' => Colors.blue,
      'ended' => theme.hintColor,
      _ => theme.colorScheme.error,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Text(status.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: color)),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const _Card({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;
  const _InfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
      const SizedBox(width: Dimensions.paddingSizeSmall),
      Expanded(child: Text(
        value, textAlign: TextAlign.end,
        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
      )),
    ]);
  }
}

class _BundleItemRow extends StatelessWidget {
  final BundleItem item;
  const _BundleItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int quantity = item.quantity ?? 1;
    final String variationSummary = item.variationSummary ?? '';
    final String addOnSummary = item.addOnSummary ?? '';

    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

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

        if(variationSummary.isNotEmpty)
          Text(
            '${'variation'.tr} : $variationSummary', maxLines: 1, overflow: TextOverflow.ellipsis,
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: theme.hintColor),
          ),

        if(addOnSummary.isNotEmpty)
          Text(
            '${'add_on'.tr} : $addOnSummary', maxLines: 1, overflow: TextOverflow.ellipsis,
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: theme.hintColor),
          ),

        Text(
          PriceConverterHelper.convertPrice((item.unitPrice ?? 0) * quantity),
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
        ),
      ])),
      const SizedBox(width: Dimensions.paddingSizeSmall),

      Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
        decoration: BoxDecoration(
          color: theme.disabledColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
        child: Text('$quantity', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
      ),
    ]);
  }
}
