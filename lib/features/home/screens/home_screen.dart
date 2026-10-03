import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sixam_mart_store/common/widgets/order_shimmer_widget.dart';
import 'package:sixam_mart_store/common/widgets/order_widget.dart';
import 'package:sixam_mart_store/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_store/features/home/widgets/ads_section_widget.dart';
import 'package:sixam_mart_store/features/home/widgets/business_analytics_widget.dart';
import 'package:sixam_mart_store/features/home/widgets/order_button_widget.dart';
import 'package:sixam_mart_store/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart_store/features/order/controllers/order_controller.dart';
import 'package:sixam_mart_store/features/order/domain/models/order_model.dart';
import 'package:sixam_mart_store/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_store/helper/bogo_offer_action_helper.dart';
import 'package:sixam_mart_store/helper/happy_hour_action_helper.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_ink_well_widget.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';

part '../widgets/permission_warning_widget.dart';
part '../widgets/bogo_offer_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AppLifecycleListener _listener;
  bool _isNotificationPermissionGranted = true;
  bool _isBatteryOptimizationGranted = true;

  @override
  void initState() {
    super.initState();

    _checkSystemNotification();

    _listener = AppLifecycleListener(
      onStateChange: _onStateChanged,
    );

    _loadData();

    Future.delayed(const Duration(milliseconds: 200), () {
      checkPermission();
    });
  }

  Future<void> _loadData() async {
    await Get.find<ProfileController>().getProfile();
    await Get.find<OrderController>().getCurrentOrders();
    await Get.find<NotificationController>().getNotificationList();
    HappyHourActionHelper.showAdminRequest();
    BogoOfferActionHelper.showAdminRequest();
  }

  Future<void> _checkSystemNotification() async {
    if(await Permission.notification.status.isDenied || await Permission.notification.status.isPermanentlyDenied) {
      await Get.find<AuthController>().setNotificationActive(false);
    }
  }

  void _onStateChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.resumed:
        Future.delayed(const Duration(milliseconds: 200), () {
          checkPermission();
        });
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.paused:
        break;
    }
  }

  Future<void> checkPermission() async {
    var notificationStatus = await Permission.notification.status;
    var batteryStatus = await Permission.ignoreBatteryOptimizations.status;

    if(notificationStatus.isDenied || notificationStatus.isPermanentlyDenied) {
      setState(() {
        _isNotificationPermissionGranted = false;
        _isBatteryOptimizationGranted = true;
      });

      await Get.find<AuthController>().setNotificationActive(!notificationStatus.isDenied);

    } else if(batteryStatus.isDenied) {
      setState(() {
        _isBatteryOptimizationGranted = false;
        _isNotificationPermissionGranted = true;
      });
    } else {
      setState(() {
        _isNotificationPermissionGranted = true;
        _isBatteryOptimizationGranted = true;
      });
      Get.find<ProfileController>().setBackgroundNotificationActive(true);
    }

    if(batteryStatus.isDenied) {
      Get.find<ProfileController>().setBackgroundNotificationActive(false);
    }
  }

  Future<void> requestNotificationPermission() async {

    if (await Permission.notification.request().isGranted) {
      return;
    } else {
      await openAppSettings();
    }

    checkPermission();
  }

  void requestBatteryOptimization() async {
    var status = await Permission.ignoreBatteryOptimizations.status;

    if (status.isGranted) {
      return;
    } else if(status.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    } else {
      openAppSettings();
    }

    checkPermission();
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        titleSpacing: 0,
        surfaceTintColor: Theme.of(context).cardColor,
        shadowColor: Theme.of(context).disabledColor.withValues(alpha: 0.5),
        elevation: 2,
        title: Padding(
          padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
          child: Image.asset(Images.logo, height: 30,),
        ),
        actions: [IconButton(
          icon: GetBuilder<NotificationController>(builder: (notificationController) {
            return Stack(children: [
              Icon(Icons.notifications, size: 25, color: Theme.of(context).textTheme.bodyLarge!.color),
              notificationController.hasNotification ? Positioned(top: 0, right: 0, child: Container(
                height: 10, width: 10, decoration: BoxDecoration(
                color: Theme.of(context).primaryColor, shape: BoxShape.circle,
                border: Border.all(width: 1, color: Theme.of(context).cardColor),
              ),
              )) : const SizedBox(),
            ]);
          }),
          onPressed: () => Get.toNamed(RouteHelper.getNotificationRoute()),
        )],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await _loadData();
        },
        child: GetBuilder<ProfileController>(builder: (profileController) {
          /// OrderController notifies the running orders with ids only, so this
          /// builder has to carry one or it never sees the loaded orders.
          return GetBuilder<OrderController>(id: 'running_header', builder: (orderController) {
            bool isEnableTemporarilyClosed = false;

            if(orderController.runningOrders != null) {
              for(int i = 0; i < orderController.runningOrders!.length; i++) {
                if(orderController.runningOrders?[i].status == 'confirmed' || orderController.runningOrders?[i].status == 'cooking'
                    || orderController.runningOrders?[i].status == 'ready_for_handover' || orderController.runningOrders?[i].status == 'food_on_the_way') {
                  if(orderController.runningOrders![i].orderList.isNotEmpty) {
                    isEnableTemporarilyClosed = true;
                    break;
                  }else {
                    isEnableTemporarilyClosed = false;
                  }
                }
              }
            }

            List<OrderModel> orderList = [];
            if(orderController.runningOrders != null) {
              orderList = orderController.runningOrders![orderController.orderIndex].orderList;
            }

            return CustomScrollView(
              slivers: [
                GetPlatform.isAndroid ? SliverToBoxAdapter(
                  child: Column(children: [
                    if(!_isNotificationPermissionGranted)
                      _PermissionWarningWidget(isBatteryPermission: false, onTap: requestNotificationPermission, closeOnTap: () {
                        setState(() {
                          _isNotificationPermissionGranted = true;
                        });
                      }),

                    if(!_isBatteryOptimizationGranted)
                      _PermissionWarningWidget(isBatteryPermission: true, onTap: requestBatteryOptimization, closeOnTap: () {
                        setState(() {
                          _isBatteryOptimizationGranted = true;
                        });
                      }),

                  ]),
                ) : const SliverToBoxAdapter(),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, top: GetPlatform.isAndroid ? 0 : Dimensions.paddingSizeDefault),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      profileController.modulePermission != null && profileController.modulePermission!.wallet!
                          ? BusinessAnalyticsWidget(profileController: profileController)
                          : const SizedBox(),
                      SizedBox(height: profileController.modulePermission != null && profileController.modulePermission!.wallet! ? Dimensions.paddingSizeExtraLarge : 0),

                      profileController.modulePermission != null && profileController.modulePermission!.advertisement! ? const AdsSectionWidget() : const SizedBox(),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      /// Hidden for rental and service stores, where buy-one-get-one
                      /// has no meaning — the same rule the menu entry uses.
                      BogoOfferActionHelper.isSupportedModule ? const _BogoOfferCard() : const SizedBox(),
                      SizedBox(height: BogoOfferActionHelper.isSupportedModule ? Dimensions.paddingSizeSmall : 0),

                    ]),
                  ),
                ),


                if(profileController.modulePermission != null && profileController.modulePermission!.order!) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                      child: Column(children: [

                        Row(children: [
                          Text('ongoing_orders'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                          const Spacer(),

                          orderController.runningOrders != null ? Padding(
                            padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeSmall),
                            child: InkWell(
                              onTap: () => orderController.toggleCampaignOnly(),
                              child: Row(children: [
                                SizedBox(
                                  height: 24, width: 24,
                                  child: Checkbox(
                                    side: BorderSide(color: Theme.of(context).disabledColor, width: 1),
                                    activeColor: Theme.of(context).primaryColor,
                                    value: orderController.campaignOnly,
                                    onChanged: (isActive) => orderController.toggleCampaignOnly(),
                                  ),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),

                                Text(
                                  'campaign_orders_only'.tr,
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                                ),
                              ]),
                            ),
                          ) : const SizedBox(),

                        ]),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        orderController.runningOrders != null ? SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: orderController.runningOrders!.length,
                            itemBuilder: (context, index) {
                              return OrderButtonWidget(
                                title: orderController.runningOrders![index].status.tr, index: index,
                                orderController: orderController, fromHistory: false,
                              );
                            },
                          ),
                        ) : const SizedBox(),

                        const SizedBox(height: Dimensions.paddingSizeDefault),
                      ]),
                    ),
                  ),

                  if(orderController.runningOrders == null)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                      sliver: SliverList.builder(
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return OrderShimmerWidget(isEnabled: orderController.runningOrders == null);
                        },
                      ),
                    )
                  else if(orderList.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 50, bottom: 100),
                          child: Center(child: Text('no_order_found'.tr)),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                      sliver: SliverList.builder(
                        itemCount: orderList.length,
                        itemBuilder: (context, index) {
                          return OrderWidget(orderModel: orderList[index], hasDivider: index != orderList.length-1, isRunning: true);
                        },
                      ),
                    ),
                ] else if(profileController.modulePermission != null) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                      child: Center(child: Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: Text('you_have_no_permission_to_access_this_feature'.tr, style: robotoMedium),
                      )),
                    ),
                  ),
                ] else ...[
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                    sliver: SliverList.builder(
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        return OrderShimmerWidget(isEnabled: orderController.runningOrders == null);
                      },
                    ),
                  ),
                ],

              ],
            );
          });
        }),
      ),

    );
  }

}

