import 'package:sixam_mart_store/util/typography.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final String? title;
  final bool isBackButtonExist;
  final Widget? menuWidget;
  final Function? onTap;
  final Widget? titleWidget;
  final TabBar? bottom;
  const CustomAppBarWidget({
    super.key,
    this.title,
    this.isBackButtonExist = true,
    this.menuWidget,
    this.onTap,
    this.titleWidget,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title:
          titleWidget ??
          Text(
            title!.toUpperCase(),
            semanticsLabel: title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: MiliTypography.heading.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
      centerTitle: true,
      leading: isBackButtonExist
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: Theme.of(context).textTheme.bodyLarge!.color,
              onPressed: onTap as void Function()? ?? () => Get.back(),
            )
          : const SizedBox(),
      backgroundColor: Theme.of(context).cardColor,
      surfaceTintColor: Theme.of(context).cardColor,
      shadowColor: Theme.of(context).disabledColor.withValues(alpha: 0.5),
      elevation: 2,
      actions: menuWidget != null ? [menuWidget!] : null,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size(
    1170,
    GetPlatform.isDesktop
        ? (bottom != null ? 120 : 70)
        : (bottom != null ? 100 : 60),
  );
}
