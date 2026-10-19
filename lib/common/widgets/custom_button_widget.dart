import 'package:get/get.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';
import 'package:flutter/material.dart';

class CustomButtonWidget extends StatelessWidget {
  final Function? onPressed;
  final String buttonText;
  final bool transparent;
  final EdgeInsets? margin;
  final double? height;
  final double? width;
  final double? fontSize;
  final Color? color;
  final IconData? icon;
  final double radius;
  final FontWeight? fontWeight;
  final bool isViewReply;
  final Color? textColor;
  final Color? iconColor;
  final bool isLoading;
  final bool isBorder;
  final bool takeMinimumWidth;
  final EdgeInsets padding;
  final Color? borderColor;
  const CustomButtonWidget({
    super.key,
    this.onPressed,
    required this.buttonText,
    this.transparent = false,
    this.margin,
    this.iconColor,
    this.isLoading = false,
    this.width,
    this.height,
    this.fontSize,
    this.color,
    this.icon,
    this.radius = Dimensions.radiusDefault,
    this.fontWeight,
    this.isViewReply = false,
    this.textColor,
    this.isBorder = false,
    this.takeMinimumWidth = false,
    this.padding = EdgeInsets.zero,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      backgroundColor: onPressed == null
          ? Theme.of(context).disabledColor
          : transparent
          ? Colors.transparent
          : color ?? Theme.of(context).primaryColor,
      minimumSize: Size(width ?? (takeMinimumWidth ? 10 : 1170), height ?? 50),
      padding: padding == EdgeInsets.zero ? const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeExtraSmall,
      ) : padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: isBorder
            ? BorderSide(
                color:
                    borderColor ??
                    Theme.of(context).disabledColor.withValues(alpha: 0.5),
              )
            : BorderSide.none,
      ),
    );

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: TextButton(
        onPressed: isLoading ? null : onPressed as void Function()?,
        style: flatButtonStyle,
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        textColor ?? Colors.white,
                      ),
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Flexible(
                    child: Text(
                      'loading'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoMedium.copyWith(
                        color: textColor ?? Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: transparent
                          ? Theme.of(context).primaryColor
                          : iconColor ?? Theme.of(context).cardColor,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                  ],
                  Flexible(
                    child: Text(
                      buttonText,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: robotoBold.copyWith(
                        color:
                            textColor ??
                            (transparent || isViewReply
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).cardColor),
                        fontSize: fontSize ?? Dimensions.fontSizeLarge,
                        fontWeight: fontWeight,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
