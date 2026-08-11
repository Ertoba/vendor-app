import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerifiedSellerBadge extends StatelessWidget {
  final bool verified;
  final double size;

  const VerifiedSellerBadge({
    super.key,
    required this.verified,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    if (!verified) {
      return const SizedBox.shrink();
    }

    final label = 'verified_store'.tr;

    return Tooltip(
      message: label,
      child: Icon(
        Icons.verified,
        size: size,
        color: const Color(0xFF3979E0),
        semanticLabel: label,
      ),
    );
  }
}
