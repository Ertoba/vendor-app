import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAssetImageWidget extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final Color? color;

  const CustomAssetImageWidget(this.image, {super.key, this.height, this.width, this.fit = BoxFit.cover, this.color});

  @override
  Widget build(BuildContext context) {
    final isSvg = image.contains('.svg', image.length - '.svg'.length);
    if (isSvg) {
      return SvgPicture.asset(
        image,
        width: height, height: width,
        colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
        fit: fit!,
      );
    }
    final double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final bool constrainByWidth = width != null && (height == null || width! >= height!);
    return Image.asset(
      image, fit: fit, width: width, height: height, color: color,
      cacheWidth: constrainByWidth ? (width! * pixelRatio).round() : null,
      cacheHeight: !constrainByWidth && height != null ? (height! * pixelRatio).round() : null,
    );
  }
}
