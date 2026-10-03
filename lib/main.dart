import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/controllers/theme_controller.dart';
import 'package:sixam_mart_store/features/home/widgets/trial_widget.dart';
import 'package:sixam_mart_store/features/language/controllers/language_controller.dart';
import 'package:sixam_mart_store/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart_store/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_store/helper/notification_helper.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/theme/dark_theme.dart';
import 'package:sixam_mart_store/theme/light_theme.dart';
import 'package:sixam_mart_store/util/app_constants.dart';
import 'package:sixam_mart_store/util/messages.dart';

import 'helper/get_di.dart' as di;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Map<String, Map<String, String>> languages = await di.init();

  if(GetPlatform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCc3OCd5I2xSlnftZ4bFAbuCzMhgQHLivA",
        appId: "1:491987943015:android:9795ba69e89c684b8f1ec2",
        messagingSenderId: "491987943015",
        projectId: "stackmart-500c7",
      ),
    );
  }else {
    await Firebase.initializeApp();
  }

  NotificationBodyModel? body;
  try {
    if (GetPlatform.isMobile) {
      final RemoteMessage? remoteMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (remoteMessage != null) {
        /// The payload the app was launched from. The foreground and background
        /// handlers log theirs too; without this one a launch-from-terminated
        /// notification is the only path with nothing to read when it routes
        /// somewhere unexpected.
        debugPrint('====> Launch notification data: ${remoteMessage.data}');
        body = NotificationHelper.convertNotification(remoteMessage.data);
      }
      await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);

      /// Only when Firebase did not launch the app itself. A notification this
      /// app drew — which is every one that arrived while the app was on screen —
      /// launches it through flutter_local_notifications instead, and carries its
      /// payload there rather than in the initial message.
      body ??= await NotificationHelper.getLaunchNotification(flutterLocalNotificationsPlugin);
      if (body != null) {
        debugPrint('====> Launch notification resolved to: ${body.notificationType}');
      }
    }
  }catch(e) {
    /// Swallowed so a notification failure can never stop the app booting — but
    /// logged, because a throw here leaves `body` null and the splash screen
    /// then routes to the dashboard as if no notification had been tapped.
    debugPrint('====> Launch notification failed: $e');
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(MyApp(languages: languages, body: body));
}

class MyApp extends StatelessWidget {
  final Map<String, Map<String, String>>? languages;
  final NotificationBodyModel? body;
  const MyApp({super.key, required this.languages, required this.body});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetBuilder<LocalizationController>(
          builder: (localizeController) {
            return GetMaterialApp(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              navigatorKey: Get.key,
              theme: themeController.darkTheme ? dark : light,
              locale: localizeController.locale,
              translations: Messages(languages: languages),
              fallbackLocale: Locale(AppConstants.languages[0].languageCode!, AppConstants.languages[0].countryCode),
              initialRoute: RouteHelper.getSplashRoute(body),
              getPages: RouteHelper.routes,
              defaultTransition: Transition.topLevel,
              transitionDuration: const Duration(milliseconds: 500),
              builder: (BuildContext context, Widget? child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1)),
                  child: Material(child: SafeArea(top: false, bottom: GetPlatform.isAndroid,
                    child: Stack(children: [
                      ?child,
                      GetBuilder<ProfileController>(
                        builder: (profileController) {
                          if (profileController.isTrialActive && !profileController.trialWidgetNotShow) {
                            return Align(alignment: Alignment.bottomRight,
                              child: Padding(padding: const EdgeInsets.only(bottom: 90),
                                child: TrialWidget(subscription: profileController.profileModel!.subscription!),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ]),
                  ),
                ));
              },
            );
          },
        );
      },
    );
  }
}