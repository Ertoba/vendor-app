import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sixam_mart_store/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_store/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixam_mart_store/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_store/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_store/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart_store/features/rental_module/chat/screens/taxi_chat_screen.dart';
import 'package:sixam_mart_store/features/rental_module/profile/controllers/taxi_profile_controller.dart';
import 'package:sixam_mart_store/features/rental_module/trips/screens/trip_details_screen.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/util/app_constants.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBodyModel? body;
  const SplashScreen({super.key, required this.body});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;
  bool _isRouting = false;

  @override
  void initState() {
    super.initState();

    bool firstTime = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      bool isConnected = result.contains(ConnectivityResult.wifi) || result.contains(ConnectivityResult.mobile);

      if(!firstTime) {
        isConnected ? ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar() : const SizedBox();
        ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: Duration(seconds: isConnected ? 3 : 6000),
          content: Text(isConnected ? 'connected'.tr : 'no_connection'.tr, textAlign: TextAlign.center),
        ));
        if(isConnected) {
          _route();
        }
      }

      firstTime = false;
    });

    Get.find<SplashController>().initSharedData();
    _route();

  }

  @override
  void dispose() {
    _onConnectivityChanged?.cancel();

    super.dispose();
  }

  void _route() {
    if (_isRouting) return;
    _isRouting = true;

    /// A notification launch routes itself below, so the config call is told not
    /// to navigate. Left to its own devices it runs `Get.offAllNamed(initial)`
    /// the moment config lands — putting the vendor on the dashboard and tearing
    /// this screen down a full second before the notification routing runs, so
    /// that routing then has to fire from a disposed widget and land on top of a
    /// stack something else already replaced.
    Get.find<SplashController>().getConfigData(closeRoute: widget.body != null).then((isSuccess) async {
      _isRouting = false;
      if (isSuccess) {
        Timer(const Duration(seconds: 1), () async {
          double? minimumVersion = _getMinimumVersion();
          bool isMaintenanceMode = Get.find<SplashController>().configModel!.maintenanceMode!;
          bool needsUpdate = AppConstants.appVersion < minimumVersion!;
          bool inMaintenanceForApp = isMaintenanceMode && Get.find<SplashController>().configModel!.maintenanceModeData!.maintenanceSystemSetup!.contains('vendor_app');

          if (needsUpdate || inMaintenanceForApp) {
            Get.offNamed(RouteHelper.getUpdateRoute(needsUpdate));
            return;
          }

          if(widget.body != null) {
            await _handleNotificationLaunch(widget.body!);
          }else{
            await _handleDefaultRouting();
          }
        });
      }
    });
  }

  double? _getMinimumVersion() {
    if (GetPlatform.isAndroid) {
      return Get.find<SplashController>().configModel!.appMinimumVersionAndroid;
    } else if (GetPlatform.isIOS) {
      return Get.find<SplashController>().configModel!.appMinimumVersionIos;
    }
    return 0;
  }

  /// Opening the app by tapping a notification, from terminated.
  ///
  /// This used to call [_handleNotificationRouting] straight away, which skipped
  /// everything [_handleDefaultRouting] does first — the signed-in check, the FCM
  /// token refresh and the profile load — and raced the navigation
  /// `getConfigData` performs on its own. The order matters: sign the vendor out
  /// if the session is gone, prepare the session if it is not, put the dashboard
  /// down as the base so the new screen has somewhere to go back to, and only
  /// then open what was tapped.
  Future<void> _handleNotificationLaunch(NotificationBodyModel notificationBody) async {
    debugPrint('====> Splash routing notification: ${notificationBody.notificationType}');

    if (!Get.find<AuthController>().isLoggedIn()) {
      Get.offAllNamed(RouteHelper.getSignInRoute());
      return;
    }

    await Get.find<AuthController>().updateToken();
    Get.find<AuthController>().getModuleType() == 'rental'
        ? await Get.find<TaxiProfileController>().getProfile()
        : await Get.find<ProfileController>().getProfile();

    Get.offAllNamed(RouteHelper.getInitialRoute());

    /// offAllNamed tears the whole stack down and builds a new one, and the
    /// screen the notification opens has to be pushed onto the stack that
    /// replaces it — not the one being torn down. Waiting for the frame to end
    /// is what makes the order deterministic rather than a race.
    await WidgetsBinding.instance.endOfFrame;
    await _handleNotificationRouting(notificationBody);
  }

  Future<void> _handleNotificationRouting(NotificationBodyModel? notificationBody) async {
    final notificationType = notificationBody?.notificationType;
    
    final Map<NotificationType, Function> notificationActions = {
      NotificationType.order: () {
        if(Get.find<AuthController>().getModuleType() == 'rental'){
          Get.to(()=> TripDetailsScreen(tripId: notificationBody!.orderId!, fromNotification: true));
        }else if(Get.find<AuthController>().getModuleType() == AppConstants.service){
          Get.toNamed(RouteHelper.getBookingDetailsRoute(notificationBody!.orderId!, fromNotification: true));
        }else{
          Get.toNamed(RouteHelper.getOrderDetailsRoute(notificationBody?.orderId, fromNotification: true));
        }
      },
      NotificationType.service_booking: () => Get.toNamed(RouteHelper.getBookingDetailsRoute(notificationBody!.orderId!, fromNotification: true)),
      NotificationType.custom_service_request: () => Get.toNamed(RouteHelper.getCustomServiceRequestDetailsRoute(notificationBody!.orderId!)),
      NotificationType.custom_service_bid_selected: () => Get.toNamed(RouteHelper.getCustomServiceRequestDetailsRoute(notificationBody!.orderId!)),
      NotificationType.custom_service_bid_denied: () => Get.toNamed(RouteHelper.getCustomServiceRequestDetailsRoute(notificationBody!.orderId!)),
      NotificationType.advertisement: () => Get.toNamed(RouteHelper.getAdvertisementDetailsScreen(advertisementId: notificationBody?.advertisementId, fromNotification: true)),
      NotificationType.block: () => Get.offAllNamed(RouteHelper.getSignInRoute()),
      NotificationType.unblock: () => Get.offAllNamed(RouteHelper.getSignInRoute()),
      NotificationType.withdraw: () => Get.to(const DashboardScreen(pageIndex: 3)),
      NotificationType.campaign: () => Get.toNamed(RouteHelper.getCampaignDetailsRoute(id: notificationBody?.campaignId, fromNotification: true)),
      NotificationType.happy_hour: () {
        if(notificationBody?.happyHourId != null) {
          Get.toNamed(RouteHelper.getHappyHourDetailsRoute(id: notificationBody!.happyHourId!, fromNotification: true));
        }
      },
      NotificationType.bogo_offer: () => Get.toNamed(notificationBody?.bogoOfferId != null
          ? RouteHelper.getBogoOfferDetailsRoute(id: notificationBody!.bogoOfferId!, fromNotification: true)
          : RouteHelper.getBogoOfferRoute(fromNotification: true)),
      NotificationType.message: () {
        if(Get.find<AuthController>().getModuleType() == 'rental'){
          Get.to(()=> TaxiChatScreen(notificationBody: notificationBody, conversationId: notificationBody?.conversationId, fromNotification: true));
        }else{
          Get.toNamed(RouteHelper.getChatRoute(notificationBody: notificationBody, conversationId: notificationBody?.conversationId, fromNotification: true));
        }
      },
      NotificationType.subscription: () async{
        if (Get.find<SplashController>().configModel == null) {
          await Get.find<SplashController>().getConfigData(closeRoute: true);
        }
        if (Get.find<ProfileController>().profileModel == null) {
          await Get.find<ProfileController>().getProfile();
        }
        return Get.toNamed(RouteHelper.getMySubscriptionRoute(fromNotification: true));
      },
      NotificationType.product_approve: () => Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true)),
      NotificationType.product_rejected: () => Get.toNamed(RouteHelper.getPendingItemRoute(fromNotification: true)),
      NotificationType.general: () => Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true)),
    };

    notificationActions[notificationType]?.call();
  }

  Future<void> _handleDefaultRouting() async {
    if (Get.find<AuthController>().isLoggedIn()) {
      await Get.find<AuthController>().updateToken();
      Get.find<AuthController>().getModuleType() == 'rental' ? await Get.find<TaxiProfileController>().getProfile() : await Get.find<ProfileController>().getProfile();
      Get.offNamed(RouteHelper.getInitialRoute());
    } else {
      final bool showIntro = Get.find<SplashController>().showIntro();
      if(AppConstants.languages.length > 1 && showIntro) {
        Get.offNamed(RouteHelper.getLanguageRoute('splash'));
      }else {
        Get.offNamed(RouteHelper.getSignInRoute());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Image.asset(Images.logo, width: 200),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text('suffix_name'.tr, style: robotoMedium, textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}