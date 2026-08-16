import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final config = Get.find<SplashController>().configModel;

    return Scaffold(
      appBar: CustomAppBarWidget(title: 'დახმარება და მხარდაჭერა'),
      backgroundColor: Theme.of(context).cardColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Center(
            child: SizedBox(
              width: 500,
              child: Column(
                children: [
                  const _SupportHero(),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  _SupportActionCard(
                    icon: Icons.location_on,
                    title: 'address'.tr,
                    color: Theme.of(context).primaryColor,
                    info: config?.address ?? '',
                    onTap: () {},
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  _SupportActionCard(
                    icon: Icons.call,
                    title: 'call'.tr,
                    color: Colors.red,
                    info: config?.phone ?? '',
                    onTap: () async {
                      final String phone = config?.phone ?? '';
                      if (await canLaunchUrlString('tel:$phone')) {
                        launchUrlString('tel:$phone');
                      } else {
                        showCustomSnackBar('${'can_not_launch'.tr} $phone');
                      }
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  _SupportActionCard(
                    icon: Icons.mail_outline,
                    title: 'email'.tr,
                    color: Theme.of(context).primaryColor,
                    info: config?.email ?? '',
                    onTap: () {
                      launchUrlString(
                        Uri(
                          scheme: 'mailto',
                          path: config?.email ?? '',
                        ).toString(),
                      );
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  _SupportActionCard(
                    icon: Icons.support_agent_rounded,
                    title: 'საპორტის ჩატი',
                    color: Theme.of(context).primaryColor,
                    info: 'გადადით საუბრის ცენტრში',
                    onTap: () =>
                        Get.toNamed(RouteHelper.getConversationListRoute()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SupportHero extends StatelessWidget {
  const _SupportHero();

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Center(
            child: Container(
              width: 240,
              height: 170,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(90),
              ),
              child: Image.asset(
                Images.brandMark,
                height: 132,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: robotoBold.copyWith(
              color: Theme.of(context).textTheme.bodyLarge!.color,
              fontSize: Dimensions.fontSizeExtraLarge,
              height: 1.25,
            ),
            children: [
              const TextSpan(text: 'ჩვენ აქ ვართ, რომ '),
              TextSpan(
                text: 'დაგეხმაროთ!',
                style: robotoBold.copyWith(color: primaryColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Text(
          'აირჩიეთ თქვენთვის სასურველი კონტაქტის გზა და დაგიკავშირდებით უმოკლეს დროში.',
          textAlign: TextAlign.center,
          style: robotoMedium.copyWith(
            color: Theme.of(context).hintColor,
            fontSize: Dimensions.fontSizeSmall,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _SupportActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String info;
  final Color color;
  final VoidCallback onTap;

  const _SupportActionCard({
    required this.icon,
    required this.title,
    required this.info,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: color.withValues(alpha: 0.10)),
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoBold.copyWith(
                      color: color,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Text(
                    info,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.10),
              ),
              child: Icon(Icons.chevron_right_rounded, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
