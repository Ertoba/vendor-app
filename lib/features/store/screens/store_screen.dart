import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart_store/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/common/widgets/sliver_delegate.dart';
import 'package:sixam_mart_store/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_store/features/store/controllers/store_controller.dart';
import 'package:sixam_mart_store/features/store/widgets/announcement_bottom_sheet_widget.dart';
import 'package:sixam_mart_store/helper/date_converter_helper.dart';
import 'package:sixam_mart_store/helper/price_converter_helper.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';

import '../../../common/widgets/item_shimmer_widget.dart';
import '../widgets/filter_popup_widget.dart';
import '../widgets/item_view_widget.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  /// Carried by each sliver rather than by the scroll view around them: a
  /// viewport clips at its own bounds, so a card sitting flush against a padded
  /// viewport edge has its shadow sliced off level with the card.
  static const EdgeInsets _horizontalPadding = EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault);

  final ScrollController _scrollController = ScrollController();

  Timer? _coverPhotoTimer;
  bool _showCoverShimmer = true;

  @override
  void initState() {
    super.initState();
    _coverPhotoTimer = Timer(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showCoverShimmer = false;
        });
      }
    });

    Get.find<ProfileController>().getProfile();
    Get.find<StoreController>().getItemList(offset: '1', type: 'all', search: '', categoryId: 0, willUpdate: false);
  }

  @override
  void dispose() {
    _coverPhotoTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(builder: (storeController) {
      return GetBuilder<ProfileController>(builder: (profileController) {
        final theme = Theme.of(context);

        /// Guarded before the unwraps below rather than after them: the profile
        /// is still null on the first frame after a sign in, and `stores` is
        /// null until the account has one attached.
        if (profileController.profileModel == null || profileController.profileModel!.stores == null
            || profileController.modulePermission == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final store = profileController.profileModel!.stores!;
        bool isShowingTrialContent = profileController.profileModel!.subscription != null
            && profileController.profileModel!.subscription!.isTrial == true
            && DateConverterHelper.differenceInDaysIgnoringTime(DateTime.parse(profileController.profileModel!.subscription!.expiryDate!), null) > 0;

        return profileController.modulePermission?.myShop == true ? Scaffold(
          backgroundColor: theme.cardColor,

          appBar: CustomAppBarWidget(title: 'my_shop'.tr, isBackButtonExist: false),

          floatingActionButton: storeController.isFabVisible && (storeController.tabIndex == 0 && profileController.modulePermission?.item == true) ? Padding(
            padding: EdgeInsets.only(bottom: isShowingTrialContent ? 100 : 0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: FloatingActionButton(
                heroTag: 'store_fab',
                onPressed: () {
                  if(Get.find<ProfileController>().profileModel!.stores!.itemSection!) {
                    Get.toNamed(RouteHelper.getAddItemRoute(null));
                  }else {
                    showCustomSnackBar('this_feature_is_blocked_by_admin'.tr);
                  }
                },
                backgroundColor: theme.primaryColor,
                child: Icon(Icons.add, color: theme.cardColor, size: 30),
              ),
            ),
          ) : const SizedBox(),

          body: RefreshIndicator(
              onRefresh: () async {
                _coverPhotoTimer?.cancel();
                setState(() {
                  _showCoverShimmer = true;
                });
                _coverPhotoTimer = Timer(Duration(seconds: 3), () {
                  if (mounted) {
                    setState(() {
                      _showCoverShimmer = false;
                    });
                  }
                });
                await Get.find<ProfileController>().getProfile();
                await Get.find<StoreController>().getItemList(offset: '1', type: 'all', search: '', categoryId: 0, willUpdate: false);
              },
            /// No padding wrapper around the scroll view: every sliver already
            /// carries its own inset, so the store card meets the app bar — its
            /// top corners are square for exactly that — and the list ends where
            /// its last card ends.
            child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                slivers: [

                  /// Store Info Section
                  SliverPadding(padding: _horizontalPadding, sliver: SliverToBoxAdapter(child: Container(
                    padding: EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      boxShadow: [BoxShadow( offset: Offset(0, 3) , color: Colors.grey[Get.isDarkMode ? 700 : 200]!, blurRadius: 8, spreadRadius: 0)],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(Dimensions.radiusLarge),
                        bottomRight: Radius.circular(Dimensions.radiusLarge)),
                    ),
                    child: Column(children: [

                      /// Cover Images
                      Stack(clipBehavior: Clip.none, children: [
                        /// Never collapses to zero height: the logo below is a
                        /// `Positioned` child of this Stack, so an empty cover
                        /// would drag it out of the card and over the details row.
                        (store.coverPhotoFullUrl ?? '').isNotEmpty ?
                          CustomImageWidget(
                            fit: BoxFit.cover,
                            placeholder: Images.restaurantCover,
                            image: '${store.coverPhotoFullUrl}',
                            width: double.infinity,
                            height: 86
                          ) : _showCoverShimmer ? Shimmer(
                            color: theme.disabledColor,
                            colorOpacity: 0.4,
                            child: SizedBox(height: 86, width: double.infinity),
                        ) : Image.asset(Images.restaurantCover, height: 86, width: double.infinity, fit: BoxFit.cover),

                        Positioned(bottom: -40, left: Dimensions.paddingSizeDefault,
                          child: Container(
                            height: 60, width: 60,
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))],
                            ),
                            child: ClipRRect(borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: (store.logoFullUrl ?? '').isNotEmpty
                                  ? CustomImageWidget(image: '${store.logoFullUrl}', height: 60, width: 60, fit: BoxFit.cover)
                              : _showCoverShimmer ? Shimmer(color: theme.disabledColor, colorOpacity: 0.4, child: SizedBox(height: 60, width: 60))
                              : Image.asset(Images.placeholder, height: 60, width: 60, fit: BoxFit.cover),
                            )
                          ),
                        ),

                      ]),

                      ///Store Details
                      store.name != null && store.address != null ? Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                          SizedBox(width: 75),
                          // Store Details
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Flexible(child: Text(store.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge))),
                              SizedBox(width: Dimensions.paddingSizeExtraSmall),

                              if(store.verifiedSeller ?? false) Image.asset(Images.verifyedBadge, width: Dimensions.fontSizeExtraLarge, height: Dimensions.fontSizeExtraLarge)
                            ]),
                            Text(store.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: theme.disabledColor)),
                          ])),
                          SizedBox(width: Dimensions.paddingSizeSmall),
                          InkWell(onTap: () {
                            if(Get.find<ProfileController>().modulePermission!.myShop!){
                              Get.toNamed(RouteHelper.getStoreEditRoute(store));
                            }else{
                              showCustomSnackBar('access_denied'.tr);
                            }}, child: Container(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.indigo),
                            child: Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                          )),
                        ]),
                      ) : _showCoverShimmer ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                        SizedBox(width: 75),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            SizedBox(height: 6),
                            Shimmer(color: theme.disabledColor, colorOpacity: 0.4, child: SizedBox(height: 20, width: double.infinity)),
                            SizedBox(height: 6),
                            Shimmer(color: theme.disabledColor, colorOpacity: 0.4, child: SizedBox(height: 14, width: double.infinity)),
                          ]),
                        ),
                        SizedBox(width: Dimensions.paddingSizeSmall),
                        Shimmer(color: theme.disabledColor, colorOpacity: 0.4, child: SizedBox(height: 36, width: 36)),
                      ]) : SizedBox.shrink(),

                      SizedBox(height: (store.delivery ?? false) && (store.freeDelivery ?? false) ? Dimensions.paddingSizeSmall : 0),

                      /// Store Info
                      store.totalItems != null && store.totalOrder != null && store.avgRating != null && store.ratingCount != null ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Expanded(child: Container(
                              padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                color: theme.disabledColor.withValues(alpha: 0.1),
                              ),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Flexible(child: FittedBox(child: Text('items'.tr))),
                                  SizedBox(width: Dimensions.paddingSizeSmall,),
                                  Image.asset(Images.itemsIcon, width: 20, height: 20),
                                ]),
                                SizedBox(height: Dimensions.paddingSizeDefault),

                                Text((store.totalItems ?? 0).toString(),
                                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: theme.primaryColor)
                                ),
                              ]),
                          )),
                        SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              color: theme.disabledColor.withValues(alpha: 0.1),
                            ),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Flexible(child: FittedBox(child: Text('orders'.tr))),
                                SizedBox(width: Dimensions.paddingSizeSmall,),
                                Image.asset(Images.ordersIcon, width: 20, height: 20),
                              ]),
                              SizedBox(height: Dimensions.paddingSizeDefault),
                              Text(store.totalOrder .toString(), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.indigo)),
                            ]),
                          )),
                        SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: GestureDetector(
                            onTap: (){
                              Get.toNamed(RouteHelper.customerReview);
                            },
                            child: Container(
                              padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                color: theme.disabledColor.withValues(alpha: 0.1),
                              ),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Flexible(child: FittedBox(child: Text('ratings'.tr))),
                                  SizedBox(width: Dimensions.paddingSizeSmall,),
                                  Image.asset(Images.ratingsIcon, width: 20, height: 20),
                                ]),
                                SizedBox(height: Dimensions.paddingSizeDefault),
                                Row(children: [
                                  Text('${store.avgRating} ', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.orange)),
                                  Text(
                                    '(${store.ratingCount})', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall,
                                    color: theme.hintColor, decoration: TextDecoration.underline, decorationColor: theme.disabledColor)),
                                ]),
                              ]),
                            ),
                          )),
                      ]) : _showCoverShimmer ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Expanded(child: Shimmer(color: theme.disabledColor, colorOpacity: 0.4, child: SizedBox(height: 56))),
                        Expanded(child: Shimmer(color: theme.disabledColor, colorOpacity: 0.4, child: SizedBox(height: 56))),
                        Expanded(child: Shimmer(color: theme.disabledColor, colorOpacity: 0.4, child: SizedBox(height: 56))),
                      ]) : SizedBox.shrink(),
                      SizedBox(height: Dimensions.paddingSizeSmall),
                    ]),
                  ))),

                  SliverPadding(padding: _horizontalPadding, sliver: SliverToBoxAdapter(child: Column(children: [
                    SizedBox(height: store.discount != null ? Dimensions.paddingSizeDefault : 0),
                    store.discount != null ? Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: theme.disabledColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      child: Row(children: [
                        SizedBox(width: Dimensions.paddingSizeSmall),
                        Image.asset(Images.discountIcon, width: 18, height: 18),
                        SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(child: Marquee(
                          text: '${store.discount!.discountType == 'percent' ? '${store.discount!.discount}% '
                            : PriceConverterHelper.convertPrice(store.discount!.discount)} '
                            '${'discount_will_be_applicable_when_order_amount_exceeds_is_more_than'.tr} ${PriceConverterHelper.convertPrice(store.discount!.minPurchase)},'
                            ' ${'max'.tr}: ${PriceConverterHelper.convertPrice(store.discount!.maxDiscount)} ${'discount_is_applicable'.tr}',
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                          scrollAxis: Axis.horizontal,
                          velocity: 40.0,
                          blankSpace: 100.0,
                          pauseAfterRound: const Duration(seconds: 1),
                          startAfter: const Duration(milliseconds: 500),
                          fadingEdgeStartFraction: 0.1,
                          fadingEdgeEndFraction: 0.1,
                        ))
                      ]),
                    ) : SizedBox.shrink(),
                  ]))),

                  /// Make Announcement Section
                  SliverPadding(padding: _horizontalPadding, sliver: SliverToBoxAdapter(child: Container(
                    margin: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                    decoration: BoxDecoration(
                     color: theme.cardColor,
                      boxShadow: [BoxShadow( offset: Offset(0, 1) , color: Colors.grey[Get.isDarkMode ? 700 : 200]!, blurRadius: 3, spreadRadius: 0)],
                    ),
                    child: Container(
                      padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.shade100.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        // boxShadow: [BoxShadow( offset: Offset(0, 3) , color: Colors.grey[Get.isDarkMode ? 700 : 200]!, blurRadius: 8, spreadRadius: 0)],
                      ),
                      child: Row(children: [
                        Image.asset(Images.adsIcon, width: 32, height: 32),
                        SizedBox(width: Dimensions.paddingSizeDefault),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('make_announcement'.tr, style: robotoBold),
                          Text('This Will be Shown in the user app/web.'.tr, style: robotoRegular.copyWith(color: theme.hintColor)),
                        ])),
                        ElevatedButton(onPressed: ()=> showAnnouncementBottomSheet(announcementStatus: store.isAnnouncementActive!, announcementMessage: store.announcementMessage ?? '', context: context),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            backgroundColor: theme.cardColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(2)),
                          ),
                          child: Text('create'.tr, style: robotoMedium.copyWith(color: Colors.black))
                        ),
                      ]),
                    ),
                  ))),

                  /// Items
                  SliverPersistentHeader(pinned: true, delegate: SliverDelegate(height: 50, child: Container(
                    width: 1170,
                    color: theme.cardColor,
                    padding: _horizontalPadding,
                    child: storeController.itemSize != null
                    ? Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        Text('items'.tr, style: robotoMedium),
                        Text('(${storeController.itemSize})', style: robotoMedium),
                        Spacer(),
                        store.module?.moduleType == 'food' ? GestureDetector(onTapDown: (details) {
                            showFilterPopup(
                              context: context,
                              offset: details.globalPosition,
                              selectedType: storeController.type,
                              onSelected: (val) {
                                storeController.setType(val);
                                storeController.getItemList(offset: '1', type: val, search: '', categoryId: storeController.categoryId);
                              },
                            );
                          }, child: Icon(Icons.filter_list, color: theme.hintColor))
                        : SizedBox.shrink(),
                      ])
                    : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Shimmer(color: theme.disabledColor, colorOpacity: 0.4, child: SizedBox(width: 86, height: 30)),
                      Shimmer(color: theme.disabledColor, colorOpacity: 0.4, child: SizedBox(width: 32, height: 30)),
                    ]),
                  ))),
                  /// `itemList` is null while the request is in flight and only
                  /// becomes `[]` once the server has actually answered with
                  /// none — so the empty message follows the data rather than a
                  /// timer that can expire mid request.
                  if (storeController.itemList == null)
                    SliverPadding(padding: _horizontalPadding, sliver: SliverToBoxAdapter(child: ItemShimmerWidget(isEnabled: true, hasDivider: false)))
                  else if (storeController.itemList!.isNotEmpty)
                    SliverPadding(padding: _horizontalPadding, sliver: SliverToBoxAdapter(child: profileController.modulePermission?.item == true
                      ? ItemViewWidget(scrollController: _scrollController, type: storeController.type,
                      onVegFilterTap: (String type) {
                        Get.find<StoreController>().getItemList(offset: '1', type: type, search: '', categoryId: 0);
                      },
                    ) : Center(child: Padding(padding: const EdgeInsets.only(top: 100),
                        child: Text('you_have_no_permission_to_access_this_feature'.tr, style: robotoMedium),
                      )),
                    ))
                  else SliverPadding(padding: _horizontalPadding, sliver: SliverToBoxAdapter(child: Center(child: Padding(padding: const EdgeInsets.only(top: 100),
                    child: Text('no_item_available'.tr, style: robotoMedium),
                  ))))
                ],
            ),
          ),
        ) : Scaffold(
          body: Center(child: Text('you_have_no_permission_to_access_this_feature'.tr, style: robotoMedium)),
        );
      });
    });
  }
}
