import 'dart:async';
import 'package:sixam_mart_store/common/widgets/navigation_safe_area.dart';
import 'package:flutter/services.dart';
import 'package:sixam_mart_store/features/home/widgets/trial_widget.dart';
import 'package:sixam_mart_store/features/language/controllers/language_controller.dart';
import 'package:sixam_mart_store/common/controllers/theme_controller.dart';
import 'package:sixam_mart_store/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart_store/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_store/helper/date_converter_helper.dart';
import 'package:sixam_mart_store/helper/notification_helper.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/theme/dark_theme.dart';
import 'package:sixam_mart_store/theme/light_theme.dart';
import 'package:sixam_mart_store/util/app_constants.dart';
import 'package:sixam_mart_store/util/messages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'helper/get_di.dart' as di;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Map<String, Map<String, String>> languages = await di.init();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp().timeout(const Duration(seconds: 15));
    }
  } catch (error, stackTrace) {
    debugPrint('Firebase init failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  NotificationBodyModel? body;

  try {
    if (GetPlatform.isMobile && Firebase.apps.isNotEmpty) {
      final RemoteMessage? remoteMessage = await FirebaseMessaging.instance
          .getInitialMessage()
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () {
              debugPrint('Firebase getInitialMessage timeout');
              return null;
            },
          );

      if (remoteMessage != null) {
        body = NotificationHelper.convertNotification(remoteMessage.data);
      }

      try {
        await NotificationHelper.initialize(
          flutterLocalNotificationsPlugin,
        ).timeout(const Duration(seconds: 8));
      } catch (error) {
        debugPrint('Notification init skipped: $error');
      }

      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    }
  } catch (error, stackTrace) {
    debugPrint('Firebase messaging init failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  runApp(MyApp(languages: languages, body: body));
}

class MyApp extends StatelessWidget {
  final Map<String, Map<String, String>>? languages;
  final NotificationBodyModel? body;
  const MyApp({super.key, required this.languages, required this.body});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

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
              fallbackLocale: Locale(
                AppConstants.languages[0].languageCode!,
                AppConstants.languages[0].countryCode,
              ),
              initialRoute: RouteHelper.getSplashRoute(body),
              getPages: RouteHelper.routes,
              defaultTransition: Transition.topLevel,
              transitionDuration: const Duration(milliseconds: 250),
              builder: (BuildContext context, widget) {
                return Material(
                  child: AppSafeArea(
                    child: Stack(
                        children: [
                          widget!,

                          GetBuilder<ProfileController>(
                            builder: (profileController) {
                              bool canShow =
                                  profileController.profileModel != null &&
                                  profileController
                                          .profileModel!
                                          .subscription !=
                                      null &&
                                  profileController
                                          .profileModel!
                                          .subscription!
                                          .isTrial ==
                                      1 &&
                                  profileController
                                          .profileModel!
                                          .subscription!
                                          .status ==
                                      1 &&
                                  DateConverterHelper.differenceInDaysIgnoringTime(
                                        DateTime.parse(
                                          profileController
                                              .profileModel!
                                              .subscription!
                                              .expiryDate!,
                                        ),
                                        null,
                                      ) >
                                      0;

                              return canShow &&
                                      !profileController.trialWidgetNotShow
                                  ? Align(
                                      alignment: Alignment.bottomRight,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 90,
                                        ),
                                        child: TrialWidget(
                                          subscription: profileController
                                              .profileModel!
                                              .subscription!,
                                        ),
                                      ),
                                    )
                                  : const SizedBox();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
              },
            );
          },
        );
      },
    );
  }
}
