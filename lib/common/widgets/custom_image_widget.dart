import 'package:cached_network_image/cached_network_image.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:flutter/cupertino.dart';

class CustomImageWidget extends StatelessWidget {
  final String image;
  final double height;
  final double width;
  final BoxFit? fit;
  final String? placeholder;
  final bool isNotification;
  const CustomImageWidget({super.key, required this.image, this.height = 8, this.width = 9, this.fit, this.placeholder, this.isNotification = false});

  @override
  Widget build(BuildContext context) {
    final double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    /// Unbounded (double.infinity) sizes can not be converted to a cache size, so only the finite side is used.
    final bool constrainByWidth = width.isFinite && (!height.isFinite || width >= height);
    final bool constrainByHeight = !constrainByWidth && height.isFinite;
    return CachedNetworkImage(
      imageUrl: image, height: height, width: width, fit: fit,
      memCacheWidth: constrainByWidth ? (width * pixelRatio).round() : null,
      memCacheHeight: constrainByHeight ? (height * pixelRatio).round() : null,
      placeholder: (context, url) => Image.asset(isNotification ? Images.notificationPlaceholder : Images.placeholder, height: height, width: width, fit: fit),
      errorWidget: (context, url, error) => Image.asset(isNotification ? Images.notificationPlaceholder : Images.placeholder, height: height, width: width, fit: fit),
    );
  }
}